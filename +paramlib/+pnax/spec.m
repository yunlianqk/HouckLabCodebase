classdef spec
    % Defines the parameters for a spectroscopy measurement for PNAX
    properties
        start = 4e9;
        stop = 5e9;
        points = 1001;
        specpower = -50;
        averages = 1000;
        avgmode = 'SWEEP';
        ifbandwidth = 5e3;
        cwfreq  = 7e9;
        cwpower = -50;
        channel = 2;
        trace = 3;
        meastype = 'S21';
        format = 'MLOG';
    end
    
    methods
        function s = toStruct(self)
            s = funclib.obj2struct(self);
        end
    end
end