classdef AmpCal < explib.RepeatGates
    % Amplitude calibration for single qubit gates
    
    % Gate sequence is initGates*(repeatGates)^n where n = 0, 1, ..., N
    % self.repeatVector specifies 0:1:N
    % Result will be zigzag shape around P(|0>) = 0.5
    % Error will be fitted and the calibrated amplitude is in self.result.newAmp

    % For X90Amplitude use X90*(X90*X90)^n
    % For Y90Amplitude use Y90*(Y90*Y90)^n
    % For X180Amplitude use X90*(X180)^n
    % For Y180Amplitude use Y90*(Y180)^n
    
    methods
        function self = AmpCal(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.RepeatGates(pulseCal, config);
            self.initGates = {'X90'};
            self.repeatGates = {'X180'};
            self.endGates = {};
            self.repeatVector = 0:1:20;
            self.histogram = 0;
        end
        
        function Run(self)
            Run@explib.RepeatGates(self);
            self.Plot();
        end
        
        function Plot(self)
            figure(102);
            fitResults = funclib.AmplitudeZigZagFit(self.repeatVector, self.result.AmpInt);
            self.result.newAmp = fitResults.updateFactor ...
                                 *self.pulseCal.([self.repeatGates{1}, 'Amplitude']);
            xlabel('Number of gates');
            ylabel('Readout amplitude');
            title([self.experimentName, ': errorInRad = ', num2str(fitResults.errorInRadians)]);
			drawnow;
        end
    end
end