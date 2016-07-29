classdef T2Experiment < handle
    % Simple T2 Experiment. Two pi/2 X pulses with varying delay. JJR 2016, Princeton
    % This experiment just uses an X pi pulse at half power for the pi/2
    % pulses, NOT a separately optimized pi/2 pulse1
    
    properties
        % change these to tweak the experiment
        qubitFreq=5e9; % qubit frequency
        gateType = 'X180';
        qubitAmplitude = .25;
        delayList = 200e-9:1e-6:10.2e-6; % delay btw qubit pulses and delay btw 2nd qubit pulse and measurement pulse
%         delayList = 200e-9:.1e-6:10.2e-6; % delay btw qubit pulses and delay btw 2nd qubit pulse and measurement pulse
        cavityFreq=7e9; % cavity frequency
        measDuration = 5e-6;
        startBuffer = 1e-6; % buffer at beginning of waveform
        endBuffer = 50e-9; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        qubit1; % qubit pulse object
        qubit2; % qubit pulse object
        measurement; % measurement pulse object
        qubit1PulseTimes; % calculated times for when 1st pulse should occur (tCenter)
        qubit2PulseTimes; % calculated times for when 2nd pulse should occur (tCenter)
        measStartTime; 
        measEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=T2Experiment()
            % constructor generates the necessary objects and calculates the dependent parameters
            % generate qubit objects
            obj.qubit1 = pulselib.singleGate(obj.gateType);
            obj.qubit1.amplitude = obj.qubitAmplitude;
            obj.qubit2 = pulselib.singleGate(obj.gateType);
            obj.qubit2.amplitude = obj.qubitAmplitude;
            % generate measurement pulse
            obj.measurement=pulselib.measPulse(obj.measDuration);
            % calculate measurement pulse times - based on the max
            % delay btw qubit and measurement
            obj.measStartTime = obj.startBuffer + max(obj.delayList*2);
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
            % calculate qubit pulse times based on the measurement time and
            % the desired delays
            for ind = 1:length(obj.delayList)
                obj.qubit1PulseTimes(ind)=obj.measStartTime-2*obj.delayList(ind);
                obj.qubit2PulseTimes(ind)=obj.measStartTime-obj.delayList(ind);
            end
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            ch2waveform = sin(2*pi*obj.cavityFreq*t); % lo waveform is always the same
            for ind=1:length(obj.delayList)
                q1=obj.qubit1;
                q2=obj.qubit2;
                [iQubit1Baseband qQubit1Baseband] = q1.uwWaveforms(t, obj.qubit1PulseTimes(ind));
                [iQubit2Baseband qQubit2Baseband] = q2.uwWaveforms(t, obj.qubit2PulseTimes(ind));
                iQB=iQubit1Baseband+iQubit2Baseband;
                qQB=qQubit1Baseband+qQubit2Baseband;
                iQubitMod=cos(2*pi*obj.qubitFreq*t).*iQB;
                qQubitMod=sin(2*pi*obj.qubitFreq*t).*qQB;
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
       