classdef Params < measlib.QPulseMeas.Params
    % Parameters for qubit life time measurements
    
    properties
        driveSigma = 10e-9;
        tStep = 0.5e-6;
        numSteps = 101;
    end
end