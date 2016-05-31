classdef Params
    % Shared parameters for pulsed measurements
    
    properties
        driveFreq = 5e-9; % Frequency for specgen
        drivePower = -5; % Power for specgen
        measDuration = 6e-6; % Duration of measurement pulse
        measFreq = 7e-9; % Frequency for rfgen
        measPower = -40; % Power for rfgen
        intFreq = 2e6; % Intermediate frequency between rfgen and logen
        loPower = 11; % Power for logen
        trigPeriod = 80e-6; % Trigger period
        numAvg = 40000; % Number of averages for digitizer
        cardDelay = 0; % Adjustable delay for digitizer
    end
    
    methods
        function s = toStruct(self)
        % Converts data object to a struct
            warning('off', 'MATLAB:structOnObject');
            s = struct(self);
            warning('on', 'MATLAB:structOnObject');
        end
    end
end

