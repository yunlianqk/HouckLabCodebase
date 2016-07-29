classdef T1Experiment < handle
    % T1 Experiment. X pulse with varying delay. JJR 2016, Princeton
    
    
    properties
        % change these to tweak the experiment
        qubitFreq=5e9; % qubit frequency
        gateType = 'X180';
        delayList = 200e-9:.1e-6:10.2e-6; % delay btw qubit pulses and measurement pulse
        cavityFreq=7e9; % cavity frequency
        measDuration = 5e-6;
        startBuffer = 1e-6; % buffer at beginning of waveform
        endBuffer = 50e-9; % buffer after measurement pulse
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
            ch2waveform = sin(2*pi*obj.cavityFreq*t); % lo waveform is always the same
            for ind=1:length(obj.delayList)
                q=obj.qubit;
                [iQubitBaseband qQubitBaseband] = q.uwWaveforms(t, obj.qubitPulseTimes(ind));
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
       