classdef BAM0Drag < explib.RepeatGates
    
    methods
        function self = BAM0Drag(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.RepeatGates(pulseCal, config);
            self.initGates = {'X90'};
            self.repeatGates = {'Y180', 'X180', 'Ym180', 'X180'};
            self.endGates = {};
            self.repeatVector = 0:1:20;
            self.histogram = 0;
            self.bgsubtraction = 1;
            self.normalization = 1;
        end
        
        function Run(self)
            Run@explib.RepeatGates(self);
            figure(10);
            plot(self.repeatVector, self.result.AmpInt);
            xlabel('Number of gates');
            ylabel('Readout amplitude');
            title(self.experimentName);
        end
    end
end