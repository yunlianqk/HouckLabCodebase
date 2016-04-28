classdef acqiris
    % Defines the parameters for Acqiris digitizer
    
    properties
        fullscale = 0.2;
        sampleinterval = 1e-9;
        samples = 10000;
        averages = 30000
        segments = 1;
        delaytime = 10e-6;
        couplemode = 'DC';
    end
end