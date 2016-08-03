classdef SweepTransmissionPower < handle
    % Simple sweep of a measurement pulse Amplitude
    
    properties
        % change these to tweak the experiment
        cavityFreq=10.1652e9;
        startAmp=1;
        stopAmp=0;
        points = 21;
        measDuration = 5e-6;
        startBuffer = 5e-6; % buffer at beginning of waveform
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        ampVector;
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=SweepTransmissionPower()
            % constructor generates the necessary objects and calculates the dependent parameters
            obj.measurement = pulselib.measPulse(obj.measDuration);
            obj.ampVector = linspace(obj.startAmp,obj.stopAmp,obj.points);
            obj.measStartTime = obj.startBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
        end
        
        function draw(obj) 
            % It is often useful to be able to visualize the experiment for debugging purposes.
            % pulse objects are abstract. To get vector waveforms you pass them a time axis vector
            t = 0:1/obj.samplingRate:(obj.waveformEndTime);
            m=obj.measurement;
            % generate baseband waveforms
            
            % makes a movie stepping through the different waveforms
            figure(145)
            for ind=1:obj.points
                m.amplitude=obj.ampVector(ind);
                [iMeasBaseband qMeasBaseband] = m.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                plot(t,iMeasMod,'b',t,qMeasMod,'r')
                pause(1)
            end
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            m=obj.measurement;
            tStep=1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            backgroundWaveform = zeros(1,length(t));
            loWaveform = sin(2*pi*obj.cavityFreq*t);
            for ind=1:obj.points
                m.amplitude=obj.ampVector(ind);
                [iMeasBaseband qMeasBaseband] = m.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*obj.cavityFreq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*obj.cavityFreq*t).*qMeasBaseband;
                ch1waveform = iMeasMod+qMeasMod;
                s1=w.newSegment(ch1waveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
                p1=w.newPlaylistItem(s1);
                % generate LO
                s2=w.newSegment(loWaveform,markerWaveform,[0 0; 1 0; 0 0; 0 0]);
                % set lo to play simultaneously
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
        
        function result = runExperimentM8195A(obj,awg,card,cardparams)
            % Experiment specific properties
            intStart=2000; intStop=6000;
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
                figure(102);
                subplot(2,2,1); imagesc(taxis,obj.ampVector,Idata);title('In phase');ylabel('Software Amplitude');xlabel('Time (\mus)');
                subplot(2,2,2); imagesc(taxis,obj.ampVector,Qdata);title('Quad phase');ylabel('Software Amplitude');xlabel('Time (\mus)');
                subplot(2,2,3); imagesc(taxis,obj.ampVector,Pdata);title('Power I^2+Q^2');ylabel('Frequency (GHz)');xlabel('Time (\mus)');
                subplot(2,2,4); plot(obj.ampVector,sqrt(Pint));ylabel('Homodyne Amplitude');xlabel('Software Amplitude');
                pause(0.01);
            end
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
        end
    end
end
       