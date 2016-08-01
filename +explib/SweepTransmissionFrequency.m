classdef SweepTransmissionFrequency < handle
    % Simple sweep of a measurement pulse frequency
    
    properties
        % change these to tweak the experiment
        startFreq=10.1e9;
        stopFreq=10.2e9;
        points = 11;
        measDuration = 5e-6;
        startBuffer = 1e-6; % buffer at beginning of waveform
        endBuffer = 50e-9; % buffer after measurement pulse
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
        
    end
end
       