classdef SPECParams
    % Defines the parameters for a spectroscopy measurement for PNAX
    
    properties (Constant)
        measclass = 'spec';
    end
    
    properties
        start = 4e9;
        stop = 5e9;
        points = 1001;
        power = -50;
        averages = 1000;
        ifbandwidth = 5e3;
        cwfreq  = 7e9;
        cwpower = -50;
        channel = 2;
        trace = 3;
        meastype = 'S21';
        format = 'MLOG';
    end
end

