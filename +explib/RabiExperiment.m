classdef RabiExperiment < handle
    % Simple Rabi Experiment. X pulse with varying power. JJR 2016, Princeton

    properties 
        % change these to tweak the experiment. 
        qubitFreq=4.766e9;
        startAmp=1;
        stopAmp=0;
        points = 101;
        gateType = 'X180';
        interPulseBuffer = 200e-9; % time between qubit pulse and measurement pulse
        cavityFreq=10.165e9; % cavity frequency
        measDuration = 5e-6;
        measStartTime = 5e-6; 
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        ampVector
        qubit; % qubit pulse object
        qubitPulseTime;
        measurement; % measurement pulse object
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=RabiExperiment()
            % constructor generates the necessary objects and calculates the dependent parameters
            obj.qubit = pulselib.singleGate(obj.gateType);
            obj.measurement=pulselib.measPulse(obj.measDuration);
            obj.ampVector = linspace(obj.startAmp,obj.stopAmp,obj.points);
            obj.qubitPulseTime = obj.measStartTime - obj.interPulseBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            loWaveform = sin(2*pi*obj.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            backgroundWaveform = zeros(1,length(t));
            for ind=1:obj.points
                q=obj.qubit;
                q.amplitude=obj.ampVector(ind);
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTime);
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                ch1waveform = iQubitMod+qQubitMod+iMeasMod+qMeasMod;
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
        
        function [tempI,tempQ] = runExperimentM8195A(obj,awg,card,cardparams)
            % integration times
            intStart=2000; intStop=5000;
            % software averages
            softavg=100;
            w = obj.genWaveset_M8195A();
            WaveLib = awg.WavesetExtractSegmentLibraryStruct(w);
            PlayList = awg.WavesetExtractPlaylistStruct(w);
%             w.drawSegmentLibrary()
%             w.drawPlaylist()
%             WaveLib = awg.ApplyCorrection(WaveLib);
            awg.Wavedownload(WaveLib);
            cardparams.segments=length(w.playlist);
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
            for i=1:softavg
                % "hardware" averaged I,I^2 data
                [tempI,tempI2,tempQ,tempQ2] = card.ReadIandQcomplicated(awg,PlayList);
                % software acumulation
                Idata=Idata+tempI;
                Qdata=Qdata+tempQ;
                Pdata=Pdata+tempI2+tempQ2;
                Pint=mean(Pdata(:,intStart:intStop)');
                
                figure(101);
                subplot(2,2,1); imagesc(taxis,obj.freqVector,Idata);title('In phase');ylabel('Frequency (GHz)');xlabel('Time (\mus)');
                subplot(2,2,2); imagesc(taxis,obj.freqVector,Qdata);title('Quad phase');ylabel('Frequency (GHz)');xlabel('Time (\mus)');
                subplot(2,2,3); imagesc(taxis,obj.freqVector,Pdata);title('Power I^2+Q^2');ylabel('Frequency (GHz)');xlabel('Time (\mus)');
                subplot(2,2,4); plot(obj.freqVector,sqrt(Pint));ylabel('Power I^2+Q^2');xlabel('Frequency (GHz)');
                pause(0.5);
            end
            Idata=Idata./softavg;
            Qdata=Qdata./softavg;
            Pdata=Pdata./softavg;
            Pint=Pint./softavg;
        end
        
    end
end
       