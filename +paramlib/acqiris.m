classdef acqiris
    % Defines the parameters for Acqiris digitizer
    
    properties
        fullscale = 0.2; % Full scale in volts, from 0.05 V to 5 V in 1, 2, 5 sequence
        sampleinterval = 1e-9; % Sampling interval in seconds, from 1 ns to 0.1 ms in 1, 2, 2.5, 4, 5 sequence
        samples = 10000; % Number of samples for each segment, from 16 to 2 Mega (2^21) in steps of 16    
        averages = 30000; % Number of averages, from 1 to 65536
        segments = 1; % Number of segments, from 1 to 8191
        delaytime = 1e-6; % Delay time from trigger to start of acquistion
        couplemode = 'DC'; % Coupling mode, 'AC' or 'DC'
        timeout = 10; % Timeout for acquisition, default value = 10 seconds
    end
end