classdef delay < handle
    % Time delay that can be used in T1 experiment, etc.
    
    properties
        name = 'delay';
        duration = 0;
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
    end
end

