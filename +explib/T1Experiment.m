classdef T1Experiment < handle
    % T1 Experiment. X pulse with varying delay. JJR 2016, Princeton
    
    
    properties
        % change these to tweak the experiment
        qubitFreq=4.766e9; % qubit frequency
        gateType = 'X180';
        delayList = 200e-9:.1e-6:10.2e-6; % delay btw qubit pulses and measurement pulse
        cavityFreq=10.165e9; % cavity frequency
        measDuration = 5e-6;
        startBuffer = 2e-6; % buffer at beginning of waveform
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        qubit; % qubit pulse object
        measurement; % measurement pulse object
        qubitPulseTimes; % calculated times for when pulses should occur (tCenter)
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=T1Experiment()
            % constructor generates the necessary objects and calculates the dependent parameters
            % generate qubit object
            obj.qubit = pulselib.singleGate(obj.gateType);
            % generate measurement pulse
            obj.measurement=pulselib.measPulse(obj.measDuration);
            % calculate measurement pulse times - based on the max
            % delay btw qubit and measurement
            obj.measStartTime = obj.startBuffer + max(obj.delayList);
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
            % calculate qubit pulse times based on the measurement time and
            % the desired delays
            for ind = 1:length(obj.delayList)
                obj.qubitPulseTimes(ind)=obj.measStartTime-obj.delayList(ind);
            end
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            loWaveform = sin(2*pi*obj.cavityFreq*t);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
%             backgroundWaveform = zeros(1,length(t));
            for ind=1:length(obj.delayList)
                q=obj.qubit;
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTimes(ind));
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQubitBaseband;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQubitBaseband;
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
%                 subplot(2,2,4); plot(obj.freqVector,sqrt(Pint));ylabel('Power I^2+Q^2');xlabel('Frequency (GHz)');
                ax=subplot(2,2,4);
                % try doing the T1 fit during softaveraging
                lambda = funclib.ExpFit(taxis,Pdata,ax);
                
            end
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
            result.lambda=lambda;
        end
        
    end
end
       