classdef trans
    % Defines the parameters for a transmission measurement for PNAX
    properties
        start = 5e9;
        stop = 6e9;
        points = 1001;
        power = -50;
        averages = 1000;
        ifbandwidth = 5e3;
        channel = 1;
        trace = 1;
        meastype = 'S21';
        format = 'MLOG';
    end
    
    methods
        function s = toStruct(self)
            s = funclib.obj2struct(self);
        end
    end
end