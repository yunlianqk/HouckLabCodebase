classdef ErrorAmplification< handle
    % Pi pulse error amplification. After an initial pi/2 pulse it will
    % vary the number of subsequent pi pulses.  
    
    properties
        % change these to tweak the experiment
        qubitFreq=5e9; % qubit frequency
        numGateVector = 1:1:10;
        iGateType = 'X180'; % initial gate (currently just use a half power pi pulse... need to rethink how this should be done after calibrations!)
        gateType = 'X180'; % repeated gate type 
        iGateAmplitude = .25;
        cavityFreq=7e9; % cavity frequency
        measDuration = 5e-6;
        measBuffer = 100e-9; % extra delay between end of last gate and start of measurement pulse
        startBuffer = 1e-6; % buffer at beginning of waveform
        endBuffer = 50e-9; % buffer after measurement pulse
        samplingRate=32e9; % sampling rate
        % these are auto calculated
        iGate; % initial qubit pulse object
        mainGate; % qubit pulse object
        sequences; % array of gateSequence objects
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        sequenceEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=ErrorAmplification()
            % constructor generates the necessary objects and calculates the dependent parameters
            obj.initSequences(); % init routine to build gate sequences
            
            % generate measurement pulse
            obj.measurement=pulselib.measPulse(obj.measDuration);
            
            % calculate measurement pulse time - based on the max number of
            % gates
            seqDurations = [obj.sequences.totalSequenceDuration];
            maxSeqDuration = max(seqDurations);
            obj.measStartTime = obj.startBuffer + maxSeqDuration + obj.measBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.duration;
            obj.waveformEndTime = obj.measEndTime+obj.endBuffer;
            % gate sequence end times are all the same. start times can be
            % calculated on the fly
            obj.sequenceEndTime = obj.measStartTime-obj.measBuffer;
        end
        
        function obj=initSequences(obj)
            % generate qubit objects
            obj.iGate= pulselib.singleGate(obj.gateType);
            obj.iGate.amplitude = obj.iGateAmplitude;
            obj.mainGate = pulselib.singleGate(obj.gateType);
            sequences(1,length(obj.numGateVector)) = pulselib.gateSequence(); % initialize empty array of gateSequence objects
            for ind = 1:length(obj.numGateVector)
                gateArray(1,obj.numGateVector(ind)) = pulselib.singleGate(); % init empty array of gate objects
                gateArray(1)=obj.iGate;
                for ind2 = 1:obj.numGateVector(ind)
                    gateArray(ind2+1) = obj.mainGate;
                end
                sequences(ind)=pulselib.gateSequence(gateArray);
            end
            obj.sequences=sequences;
        end
        
        function w = genWaveset_M8195A(obj)
            w = paramlib.M8195A.waveset();
            tStep = 1/obj.samplingRate;
            t = 0:tStep:(obj.waveformEndTime);
            ch2waveform = sin(2*pi*obj.cavityFreq*t); % lo waveform is always the same
            for ind=1:length(obj.sequences)
                s = obj.sequences(ind);
                tStart = obj.sequenceEndTime - s.totalSequenceDuration;
                [iQubitBaseband qQubitBaseband] = s.uwWaveforms(t, tStart);
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
       