classdef SweepTransmissionPhase < handle
    % Simple sweep of a measurement pulse frequency
    
    properties
        experimentName='SweepTransmissionPhase';
        % change these to tweak the experiment
%         startFreq=6.8e9;
%         stopFreq=7e9;
        Freq = 10e9;
        startPhase = 0;
        stopPhase = 2*pi;
        points = 101;
        measDuration = 10e-6;
%         measAmplitude = 0.63; % measurement pulse amp.
        measAmplitude = .1; % measurement pulse amp.
        startBuffer = 5e-6; % buffer at beginning of waveform
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        phaseVector;
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=SweepTransmissionPhase()
            % constructor generates the necessary objects and calculates the dependent parameters
            obj.measurement = pulselib.measPulse(obj.measDuration);
            obj.measurement.amplitude = obj.measAmplitude;
%             obj.freqVector = linspace(obj.startFreq,obj.stopFreq,obj.points);
            obj.phaseVector = linspace(obj.startPhase,obj.stopPhase,obj.points);
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
            [iMeasBaseband qMeasBaseband] = m.uwWaveforms(t,obj.measStartTime);
            % makes a movie stepping through the different waveforms
            figure(145)
            for ind=1:obj.points
                phase = obj.phaseVector(ind);
                freq = obj.Freq;
                iMeasMod=cos(2*pi*freq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*freq*t).*qMeasBaseband;
                plot(t,iMeasMod,'b',t,qMeasMod,'r')
                pause(1)
            end
        end
        
        function w = genWaveset_M8195A(obj)
            display('Generating Waveset')
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            backgroundWaveform = zeros(1,length(t));
            for ind=1:obj.points
                phase = obj.phaseVector(ind);
                freq=obj.Freq;
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*freq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*freq*t).*qMeasBaseband;
                ch1waveform = iMeasMod+qMeasMod;
                s1=w.newSegment(ch1waveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
                p1=w.newPlaylistItem(s1);
                % generate LO
                loWaveform = sin(2*pi*freq*t+phase);
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
            display('running experiment')
            % Experiment specific properties
%             intStart=2000; intStop=6000;
%             softavg=100;
            intStart=1; intStop=4000;
            softavg=50;
            w = obj.genWaveset_M8195A();
            WaveLib = awg.WavesetExtractSegmentLibraryStruct(w);
            PlayList = awg.WavesetExtractPlaylistStruct(w);
%             w.drawSegmentLibrary()
%             w.drawPlaylist()
%             WaveLib = awg.ApplyCorrection(WaveLib);
            awg.Wavedownload(WaveLib);
            cardparams.segments=length(w.playlist);
%             cardparams.delaytime=obj.measStartTime-1e-6;
            cardparams.delaytime=obj.measStartTime-1e-6;
%             cardparams.delaytime=obj.measStartTime+1.5e-6;
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
                Pdata=Pdata+tempI2+tempQ2;
                Pint=mean(Pdata(:,intStart:intStop)');
                phaseData = phaseData + atan(tempQ./tempI);
                phaseInt = mean(phaseData(:,intStart:intStop)');
                
                
                figure(123);
                subplot(2,3,1); imagesc(taxis,obj.phaseVector./(2*pi),Idata);title(['In phase. N=' num2str(i)]);ylabel('Phase (2pi)');xlabel('Time (\mus)');
                subplot(2,3,2); imagesc(taxis,obj.phaseVector./(2*pi),Qdata);title('Quad phase');ylabel('Phase (2pi)');xlabel('Time (\mus)');
                subplot(2,3,4); imagesc(taxis,obj.phaseVector./(2*pi),Pdata);title('Power I^2+Q^2');ylabel('Phase (2pi)');xlabel('Time (\mus)');
                subplot(2,3,5); imagesc(taxis,obj.phaseVector./(2*pi),phaseData);title('Phase atan(Q/I)');ylabel('Phase (2pi)');xlabel('Time (\mus)');
                subplot(2,3,3); plot(obj.phaseVector./(2*pi),sqrt(Pint));ylabel('Homodyne Amplitude');xlabel('Phase (2pi)');
                subplot(2,3,6); plot(obj.phaseVector./(2*pi),phaseInt);ylabel('Integrated Phase');xlabel('Phase (2pi)');
                drawnow
            end
            result.taxis = taxis;
            result.Idata=Idata./softavg;
            result.Qdata=Qdata./softavg;
            result.Pdata=Pdata./softavg;
            result.Pint=Pint./softavg;
            display('Experiment Finished')
        end
        
    end
end
       