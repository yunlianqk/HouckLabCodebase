classdef Y90AmpCal < explib.RepeatGates

    methods
        function self = Y90AmpCal(pulseCal)
            self = self@explib.RepeatGates(pulseCal);
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
            figure(102);
            fitResults = funclib.AmplitudeZigZagFit(self.repeatVector, self.result.AmpInt);
            self.result.newAmp = self.gatedict.Y90.amplitude*fitResults.updateFactor;
            xlabel('Number of gates');
            ylabel('Readout amplitude');
            title([self.experimentName, ': errorInRad = ', num2str(fitResults.errorInRadians)]);
        end
    end
end