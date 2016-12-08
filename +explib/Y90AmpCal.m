classdef Y90AmpCal < explib.RepeatGates
    % Amplitude calibration for Y90 gate.
    % Gate sequence is Y90*(Y90*Y90)^n where n = 0, 1, ..., N
    % self.repeatVector specifies 0:1:N
    % Result will be zigzag shape around P(|0>) = 0.5
    % Error will be fitted and the calibrated amplitude is in self.result.newAmp

    methods
        function self = Y90AmpCal(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.RepeatGates(pulseCal, config);
            self.initGates = {'Y90'};
            self.repeatGates = {'Y90', 'Y90'};
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
            figure(102);
            fitResults = funclib.AmplitudeZigZagFit(self.repeatVector, self.result.AmpInt);
            self.result.newAmp = self.pulseCal.Y90Amplitude*fitResults.updateFactor;
            xlabel('Number of gates');
            ylabel('Readout amplitude');
            title([self.experimentName, ': errorInRad = ', num2str(fitResults.errorInRadians)]);
        end
    end
end