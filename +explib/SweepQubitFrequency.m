classdef SweepQubitFrequency < handle
    % simple sweep of a qubit pulse frequency.
    
    properties
        % change these to tweak the experiment
        startFreq=.01e9;
        stopFreq=5e9;
        points = 11;
        gateType = 'X180';
        interPulseBuffer = 200e-9; % time between qubit pulse and measurement pulse
        cavityFreq=7e9; % cavity frequency
        measDuration = 5e-6;
        measStartTime = 5e-6; 
        endBuffer = 50e-9; % buffer after measurement pulse
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
            obj.measurement=pulselib.measPulse(obj.measDuration);
            obj.freqVector = linspace(obj.startFreq,obj.stopFreq,obj.points);
            obj.qubitPulseTime = obj.measStartTime - obj.interPulseBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
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
                s1=w.newSegment(ch1waveform);
                p1=w.newPlaylistItem(s1);
                % since s2 will be played simultaneously with s1, it does
                % not need its own playlist item!
                ch2waveform = sin(2*pi*obj.cavityFreq*t);
                slo=w.newSegment(ch2waveform,[0 0; 1 0; 0 0; 0 0]);
                % set lo to play simultaneously
                slo.id = s1.id;
            end
            % last playlist item must have advance set to 'auto'
            p1.advance='Auto';
        end
    end
end
       