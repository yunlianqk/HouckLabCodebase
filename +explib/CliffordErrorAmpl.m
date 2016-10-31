classdef CliffordErrorAmpl < handle
    

    properties 
        experimentName = 'CliffordErrorAmpl';
        % inputs
        pulseCal;
%         numGateVector = 0:1:40; % list of # of pi pulses to be done in each sequence
        numGateVector = 0:1:20; % list of # of pi pulses to be done in each sequence
        softwareAverages = 20; 
        % Dependent properties auto calculated in the update method
%         iGate; % initial qubit pulse object
%         mainGate; % qubit pulse object
%         zeroGate; % qubit pulse (identity) for normalization
%         oneGate; % qubit pulse (X180) for normalization
        sequences; % array of gateSequence objects
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        sequenceEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=CliffordErrorAmpl(pulseCal,varargin)
            % constructor. Overwrites numGateVector if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.numGateVector = varargin{1};
                case 2
                    obj.numGateVector = varargin{1};
                    obj.softwareAverages = varargin{2};
            end
            obj.update();
        end
        
        function obj=update(obj)
            % run this to update dependent parameters after changing
            % experiment details
            obj.initSequences(); % init routine to build gate sequences
            
            % generate measurement pulse
            obj.measurement = obj.pulseCal.measurement();
            
            % calculate measurement pulse time - based on the max number of
            % gates
            seqDurations = [obj.sequences.totalSequenceDuration];
            maxSeqDuration = max(seqDurations);
            obj.measStartTime = obj.pulseCal.startBuffer + maxSeqDuration + obj.pulseCal.measBuffer;
            obj.measEndTime = obj.measStartTime+obj.measurement.totalDuration;
            obj.waveformEndTime = obj.measEndTime+obj.pulseCal.endBuffer;
            % gate sequence end times are all the same. start times can be
            % calculated on the fly
            obj.sequenceEndTime = obj.measStartTime-obj.pulseCal.measBuffer;
        end
        
        function obj=initSequences(obj)
            % generate qubit objects
%             obj.iGate = obj.pulseCal.X90();
%             obj.mainGate = obj.pulseCal.X180();
%             obj.zeroGate = obj.pulseCal.Identity();
%             obj.oneGate = obj.pulseCal.X180(); % do i want to switch this?
            
            sequences(1,length(obj.numGateVector)) = pulselib.gateSequence(); % initialize empty array of gateSequence objects
            for ind = 1:length(obj.numGateVector)
                gateArray(1,obj.numGateVector(ind)+1) = pulselib.singleGate(); % init empty array of gate objects
                gateArray(1)=obj.iGate;
                if obj.numGateVector(ind) > 0
                    for ind2 = 1:obj.numGateVector(ind)
                        gateArray(ind2+1) = obj.mainGate;   
                    end
                end
                sequences(ind)=pulselib.gateSequence(gateArray);
            end
            % create 0 and 1 normalization sequences at end
            sequences(ind+1)=pulselib.gateSequence(obj.zeroGate);
            sequences(ind+2)=pulselib.gateSequence(obj.oneGate);
            obj.sequences=sequences;
        end
        
        
    end
end