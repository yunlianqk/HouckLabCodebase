classdef AzimuthCal < explib.RepeatGates
    % Azimuth calibration for single qubit gates
    
    % Result will start from P(|0>) = 0.5 and linearly increase/decrease
    % depending on the azimuth error
    % Adjust Y180Azumith until result is flat
    
    % For Y180Azimuth use X90*(Ym180*X180*Y180*X180)^n*Y90
    % For Y90Azimuth use X90*(Ym90*Ym90*X180*Y90*Y90*X180)^n*Y90
    % For X90Azimuth use Y90*(X90*X90*Y180*Xm90*Xm90*Y180)^n*X90
    
    methods
        function self = AzimuthCal(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.RepeatGates(pulseCal, config);
            self.initGates = {'X90'};
            self.repeatGates = {'Ym180', 'X180', 'Y180', 'X180'};
            self.endGates = {'Y90'};
            self.repeatVector = 0:1:20;
            self.histogram = 0;
        end
    end
end