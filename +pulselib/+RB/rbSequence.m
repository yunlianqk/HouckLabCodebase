classdef rbSequence < handle
    % Randomized Benchmarking Sequence. Composed of an array of clifford gate
    % objects. 
    
    properties
        seqList; % list of clifford gates to be done in this sequence
        pulses; % cliffordGate object array, in order to be done
        unitary; % action of rbseequence w/out undo gate
        undoUnitary; % the action of the final pulse that is supposed to bring it back to the ground state
    end
    
    methods
        function obj = rbSequence(seqList, cliffords)
            % generate the rbSequence object.
            % inputs - seqList: a vector of #s corresponding the which cliffords to do (i.e. the 'sequence') 
            % cliffords is an array of clifford gate objects 
            obj.seqList = seqList;
            obj.pulses = cliffords(1);
            for ind = 1:length(seqList)
                obj.pulses(ind) = cliffords(seqList(ind));
            end
            % find unitary for sequence (before adding undo gate)
            obj.unitary = eye(2);
            for ind = 1:length(seqList)
                obj.unitary = obj.pulses(ind).unitary*obj.unitary;
            end
            obj.undoGate(cliffords);
        end
        
        function obj = undoGate(obj, cliffords)
            % finds undo gate and appends it to the sequence
            G = obj.unitary;
            % compare undo gate to list of cliffords to find index
            for ind = 1:length(cliffords)
                c = cliffords(ind).unitary;
                if (abs(trace(c*G)) >= (2-1e-6)) % dimension of 2 hardcoded here... only works for 1 qubit
                    obj.pulses(end+1) = cliffords(ind);
                    obj.seqList = [obj.seqList, ind];
                    obj.undoUnitary = c;
                    break
                end
            end
        end
    end
end