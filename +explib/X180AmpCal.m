classdef X180AmpCal < explib.RepeatGates
    % Amplitude calibration for X180 gate.
    % Gate sequence is X90*(X180)^n where n = 0, 1, ..., N
    % self.repeatVector specifies 0:1:N
    % Result will be zigzag shape around P(|0>) = 0.5
    % Error will be fitted and the calibrated amplitude is in self.result.newAmp
    
    methods
        function self = X180AmpCal(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.RepeatGates(pulseCal, config);
            self.initGates = {'X90'};
            self.repeatGates = {'X180'};
            self.endGates = {};
            self.repeatVector = 0:1:20;
            self.histogram = 0;
            self.bgsubtraction = 1;
            self.normalization = 1;
        end
        
        function Run(self)
            Run@explib.RepeatGates(self);
            self.Plot();
        end
        
        function Plot(self)
            figure(104);
            fitResults = funclib.AmplitudeZigZagFit(self.repeatVector, self.result.AmpInt);
            self.result.newAmp = self.pulseCal.X180Amplitude*fitResults.updateFactor;
            xlabel('Number of gates');
            ylabel('Readout amplitude');
            title([self.experimentName, ': errorInRad = ', num2str(fitResults.errorInRadians)]);
        end
    end
end