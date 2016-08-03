classdef SweepTransmissionFrequency < handle
    % Simple sweep of a measurement pulse frequency
    
    properties
        % change these to tweak the experiment
        startFreq=10.16e9;
        stopFreq=10.17e9;
        points = 101;
        measDuration = 5e-6;
%         measAmplitude = 0.35/2; % measurement pulse amp.
        measAmplitude = 1; % measurement pulse amp.
        startBuffer = 5e-6; % buffer at beginning of waveform
        endBuffer = 5e-6; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        freqVector;
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=SweepTransmissionFrequency()
            % constructor generates the necessary objects and calculates the dependent parameters
            obj.measurement = pulselib.measPulse(obj.measDuration);
            obj.freqVector = linspace(obj.startFreq,obj.stopFreq,obj.points);
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
                freq = obj.freqVector(ind);
                iMeasMod=cos(2*pi*freq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*freq*t).*qMeasBaseband;
                plot(t,iMeasMod,'b',t,qMeasMod,'r')
                pause(1)
            end
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            markerWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
            backgroundWaveform = zeros(1,length(t));
            for ind=1:obj.points
                freq=obj.freqVector(ind);
                [iMeasBaseband qMeasBaseband] = obj.measurement.uwWaveforms(t,obj.measStartTime);
                iMeasMod=cos(2*pi*freq*t).*iMeasBaseband;
                qMeasMod=sin(2*pi*freq*t).*qMeasBaseband;
                ch1waveform = iMeasMod+qMeasMod;
                s1=w.newSegment(ch1waveform,markerWaveform,[1 0; 0 0; 0 0; 0 0]);
                p1=w.newPlaylistItem(s1);
                % generate LO
                loWaveform = sin(2*pi*freq*t);
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
        
        function [tempI,tempQ] = runExperimentM8195A(obj,awg,card,cardparams)
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
            intStart=2000; intStop=5000;
            softavg=100;
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
                subplot(2,2,4); plot(obj.freqVector,Pint);ylabel('Power I^2+Q^2');xlabel('Frequency (GHz)');
                pause(0.5);
            end
            Idata=Idata./softavg;
            Qdata=Qdata./softavg;
            Pdata=Pdata./softavg;
            Pint=Pint./softavg;
        end
        
    end
end
       