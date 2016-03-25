classdef TRANSParams
    % Defines the parameters for a transmission measurement for PNAX
    
    properties (Constant)
        measclass = 'trans';
    end
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
end

