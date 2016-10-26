classdef SweepQubitFrequency < handle
    % Simple Rabi Experiment. X pulse with varying power. JJR 2016, Princeton
    
    properties
        % change these to tweak the experiment
        startFreq=4.7e9;
        stopFreq=4.84e9;
        points = 101;
        gateType = 'X180';
        qubitAmp = .7; % qubit pulse amplitude
        qubitSigma = 4e-9; % qubit pulse sigma
        interPulseBuffer = 200e-9; % time between qubit pulse and measurement pulse
%         cavityFreq=10.1657e9; % cavity frequency
        cavityFreq=10.165600e9; % cavity frequency
        cavityAmp=.6;       % cavity pulse amplitude
        measDuration = 10e-6;
        measStartTime = 5e-6; 
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        freqVector;
        qubit; % qubit pulse object
        qubitPulseTime;
        measurement; % measurement pulse object
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=SweepQubitFrequency()
            % constructor generates the necessary objects and calculates the dependent parameters
            obj.qubit = pulselib.singleGate(obj.gateType);
            obj.qubit.amplitude = obj.qubitAmp;
            obj.qubit.sigma = obj.qubitSigma;
            obj.qubit.cutoff = 4*obj.qubitSigma;
            obj.measurement=pulselib.measPulse(obj.measDuration,obj.cavityAmp);
            obj.freqVector = linspace(obj.startFreq,obj.stopFreq,obj.points);
            obj.qubitPulseTime = obj.measStartTime - obj.interPulseBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
        end
        
        function w = genWaveset_M8195A(obj)
            display('generating waveset')
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            loWaveform = sin(2*pi*obj.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
%             backgroundWaveform = zeros(1,length(t));
            for ind=1:obj.points
                q=obj.qubit;
                freq=obj.freqVector(ind);
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTime);
                iQubitMod=cos(2*pi*freq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*freq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
                % background is measurement pulse to get contrast
                backgroundWaveform = iMeasMod+qMeasMod;
                s1=w.newSegment(ch1waveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
                p1=w.newPlaylistItem(s1);
                % create LO segment with same id to play simultaneously
                s2=w.newSegment(loWaveform,markerWaveform,[0 0; 1 0; 0 0; 0 0]);
                s2.id = s1.id;
                % add background to playlist
                sBack = w.newSegment(backgroundWaveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
                pBack = w.newPlaylistItem(sBack);
                % add lo to play @ same time as background
                s3=w.newSegment(loWaveform,markerWaveform,[0 0; 1 0; 0 0; 0 0]);
                s3.id = sBack.id;
            end
            % last playlist item must have advance set to 'auto'
            pBack.advance='Auto';
        end
        
        function [result] = runExperimentM8195A(obj,awg,card,cardparams)
            display('running experiment')
            % integration times
            intStart=4000; intStop=8000;
            % software averages
            softavg=10;
            w = obj.genWaveset_M8195A();
            WaveLib = awg.WavesetExtractSegmentLibraryStruct(w);
            PlayList = awg.WavesetExtractPlaylistStruct(w);
%             w.drawSegmentLibrary()
%             w.drawPlaylist()
%             WaveLib = awg.ApplyCorrection(WaveLib);
            awg.Wavedownload(WaveLib);
            clear WaveLib;
            cardparams.segments=length(w.playlist);
            clear w; 
            cardparams.delaytime=obj.measStartTime-1e-6;
            card.SetParams(cardparams);
            tstep=1/card.params.samplerate;
            taxis=(tstep:tstep:card.params.samples/card.params.samplerate)'./1e-6;%mus units
            % READ
            % intialize matrices
            samples=uint64(cardparams.samples);
            Idata=zeros(cardparams.segments/2,samples);
            Qdata=zeros(cardparams.segments/2,samples);
            Pdata=zeros(cardparams.segments/2,samples);
            phaseData=zeros(cardparams.segments/2,samples); 
            for i=1:softavg
                % "hardware" averaged I,I^2 data
                [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,PlayList);
                % software acumulation
                Idata=Idata+tempI;
                Qdata=Qdata+tempQ;
%                 Pdata=Pdata+tempI2+tempQ2;
                Pdata=Idata.^2+Qdata.^2;
                Pint=mean(Pdata(:,intStart:intStop)');
                phaseData = phaseData + atan(tempQ./tempI);
                phaseInt = mean(phaseData(:,intStart:intStop)');
                
                figure(101);
                subplot(2,3,1); imagesc(taxis,obj.freqVector,Idata/i);title(['In phase. N=' num2str(i)]);ylabel('Frequency (GHz)');xlabel('Time (\mus)');
                subplot(2,3,2); imagesc(taxis,obj.freqVector,Qdata/i);title('Quad phase');ylabel('Frequency (GHz)');xlabel('Time (\mus)');
                subplot(2,3,4); imagesc(taxis,obj.freqVector,Pdata/i);title('Power I^2+Q^2');ylabel('Frequency (GHz)');xlabel('Time (\mus)');
                subplot(2,3,5); imagesc(taxis,obj.freqVector./1e9,phaseData/i);title('Phase atan(Q/I)');ylabel('Frequency (GHz)');xlabel('Time (\mus)');
                subplot(2,3,3); plot(obj.freqVector,sqrt(Pint)/i);ylabel('Power I^2+Q^2');xlabel('Frequency (GHz)');
                subplot(2,3,6); plot(obj.freqVector./1e9,phaseInt);ylabel('Integrated Phase');xlabel('Software Amplitude');
                pause(0.01);
            end
            result.taxis = taxis;
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg^2;
            result.Pint=Pint./softavg^2;
        end
        
    end
end
       