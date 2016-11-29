classdef X180DragCal < explib.RepeatGates

    methods
        function self = X180DragCal(pulseCal)
            self = self@explib.RepeatGates(pulseCal);
            self.initGates = {};
            self.repeatGates = {'Xm180', 'X180'};
            self.endGates = {'X90'};
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