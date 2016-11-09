classdef delay < handle
    % Time delay that can be used in T1 experiment, etc.
    
    properties
        name = 'Delay';
        duration = 0;
        unitary = eye(2);
    end
    
    properties (Dependent, SetAccess = private)
        totalDuration;
    end
    
    methods
        function self = delay(duration)
            self.duration = duration;
        end
        
        function value = get.totalDuration(self)
            value = self.duration;
        end
        
        function [iBaseband, qBaseband] = uwWaveforms(~, tAxis, ~)
            iBaseband = zeros(1, length(tAxis));
            qBaseband = iBaseband;
        end
        
        function [stateOut, stateTilt, stateAzimuth] = actOnState(~, stateIn)
            stateOut = stateIn;
            stateTilt = 2*acos(abs(stateOut(1)));
            stateAzimuth = angle(stateOut(2))-angle(stateOut(1));
        end
    end
    
    
end

