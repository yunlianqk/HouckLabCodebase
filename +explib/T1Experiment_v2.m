classdef T1Experiment_v2 < handle
    % T1 Experiment. X pulse with varying delay. JJR 2016, Princeton
    
    properties 
        experimentName = 'T1Experiment_v2';
        % inputs
        pulseCal;
        delayList = .2e-6:1.50e-6:150.2e-6; % total delay from 1st to last pulse
        softwareAverages = 5; 
        % Dependent properties auto calculated in the update method
        qubit; % main pulse
        zeroGate; % qubit pulse (identity) for normalization
        oneGate; % qubit pulse (X180) for normalization
        sequences; % gateSequence objects
        measurement; % measurement pulse object
        measStartTime; 
        measEndTime;
        sequenceEndTime;
        waveformEndTime;
    end
    
    methods
        function obj=T1Experiment_v2(pulseCal,varargin)
            % constructor. Overwrites delayList if it is passed as an input
            % then calls the update function to calculate dependent
            % properties. If these are changed after construction, rerun
            % update method.
            obj.pulseCal = pulseCal;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.delayList = varargin{1};
                case 2
                    obj.delayList = varargin{1};
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
            obj.qubit = obj.pulseCal.X180();
            obj.zeroGate = obj.pulseCal.Identity();
            obj.oneGate = obj.pulseCal.X180(); 
                        
            sequences(1,length(obj.delayList)) = pulselib.gateSequence(); % initialize empty array of gateSequence objects
            for ind = 1:length(obj.delayList)
                delayGateTime = obj.delayList(ind)/2 - obj.X90.totalDuration; % so that pulse delays match the delayList
                delayGate = obj.pulseCal.Delay(delayGateTime);
                gateArray = [obj.X90 delayGate obj.X180 delayGate obj.X90];
                sequences(ind)=pulselib.gateSequence(gateArray);
            end
            % create 0 and 1 normalization sequences at end
            sequences(ind+1)=pulselib.gateSequence(obj.zeroGate);
            sequences(ind+2)=pulselib.gateSequence(obj.oneGate);
            obj.sequences=sequences;
        end