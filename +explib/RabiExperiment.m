classdef RabiExperiment < handle
    % Simple Rabi Experiment. X pulse with varying power. JJR 2016, Princeton

    properties 
        % change these to tweak the experiment. 
        qubitFreq=5e9;
        startAmp=1;
        stopAmp=0;
        points = 11;
        gateType = 'X180';
        interPulseBuffer = 200e-9; % time between qubit pulse and measurement pulse
        cavityFreq=7e9; % cavity frequency
        measDuration = 5e-6;
        measStartTime = 5e-6; 
        endBuffer = 50e-9; % buffer after measurement pulse
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
        function obj=RabiExperiment2()
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
            ch2waveform = sin(2*pi*obj.cavityFreq*t); % lo waveform is always the same
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
                s1=w.newSegment(ch1waveform);
                p1=w.newPlaylistItem(s1);
                % since s2 will be played simultaneously with s1, it does
                % not need its own playlist item!
                slo=w.newSegment(ch2waveform,[0 0; 1 0; 0 0; 0 0]);
                % set lo to play simultaneously
                slo.id = s1.id;
            end
            % last playlist item must have advance set to 'auto'
            p1.advance='Auto';
        end
    end
end
       