classdef cliffordGate < handle
    % Clifford gate which is a composite of some primitive gates.
    
    properties
        name; % string generated using index of generated clifford
        unitary; % a 2x2 matrix corresponding to the action of the clifford
        primDecomp; % cellstr containing the name of primitive gates.
    end
    
    methods
        function self = cliffordGate(index, unitary, primDecomp)
            self.name = ['C', num2str(index)];
            self.unitary = unitary;
            self.primDecomp = primDecomp;
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(self, stateIn)
            % given an input state vector act with unitary and return final state 
            stateOut = self.unitary*stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2)) - angle(stateOut(1));
        end
    end
end