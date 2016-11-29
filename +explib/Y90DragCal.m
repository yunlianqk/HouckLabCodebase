classdef Y90DragCal < explib.RepeatGates

    methods
        function self = Y90DragCal(pulseCal)
            self = self@explib.RepeatGates(pulseCal);
            self.initGates = {};
            self.repeatGates = {'Ym90', 'Y90'};
            self.endGates = {};
            self.repeatVector = 0:1:20;
            self.histogram = 0;
            self.bgsubtraction = 1;
            self.normalization = 1;
        end
        
        function Run(self)
            Run@explib.RepeatGates(self);
        end
    end
end