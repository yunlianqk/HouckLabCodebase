classdef AmpCal < measlib.RepeatGates
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
            self = self@measlib.RepeatGates(pulseCal, config);
            self.initGates = {'X90'};
            self.repeatGates = {'X180'};
            self.endGates = {};
            self.repeatVector = 0:1:20;
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 105;
            end
            self.Integrate();
            self.Normalize();
            figure(fignum);
            fitResult = funclib.AmplitudeZigZagFit(self.repeatVector, self.result.ampInt);
            self.result.newAmp = fitResult.updateFactor ...
                                 *self.pulseCal.([self.repeatGates{1}, 'Amplitude']);
            xlabel('Number of gates');
            ylabel('P(|1>)');
            title(sprintf('Error = %f, new amplitude = %.3f', ...
                  fitResult.errorInRadians, self.result.newAmp));
        end
    end
end