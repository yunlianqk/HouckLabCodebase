classdef psweep
    % Defines the parameters for a power sweep measurement for PNAX
    properties (Constant)
        measclass = 'psweep';
    end
    
    properties
        start = -20;
        stop = -10;
        points = 1001;
        averages = 1000;
        ifbandwidth = 5e3;
        cwfreq  = 7e9;
        channel = 3;
        trace = 5;
        meastype = 'S21';
        format = 'MLOG';
    end
end