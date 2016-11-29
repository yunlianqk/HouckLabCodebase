classdef RepeatGates < explib.SweepM8195
    % Running gates in repeated pattern
    
    % Typically for error amplification in gate calibration
    % The pattern is defined as initGates*(repeatGates)^n*endGates
    % where n is specified by repeatVector
    % init/repeat/end Gates are all cellstr's that contain the names of gates
    % Example:
    % initGates = {'X90'}, repeatGates = {'X180', 'Y180'}, endGates = {'Y90'}
    % repeatVector = 0:2:4
    % generates the following sequence:
    % X90*Y90, X90*(X180*Y180)^2*Y90, X90*(X180*Y180)^4*Y90
    
    % All primary gates are stored in self.gatedict and can be accessed by
    % self.gatedict.(name), e.g. self.gatedic.('X180') returns the X180 gate
    
    properties 
        initGates;
        repeatGates;
        endGates;
        repeatVector;
    end
    
    properties (SetAccess = private)
        gatedict;
    end
    
    methods
        function self = RepeatGates(pulseCal)
            self = self@explib.SweepM8195(pulseCal);
            self.histogram = 0;
        end

        function SetUp(self)
            % Construct and store primary gates
            self.gatedict.Identity = self.pulseCal.Identity();
            self.gatedict.X180 = self.pulseCal.X180();
            self.gatedict.Xm180 = self.pulseCal.Xm180();
            self.gatedict.X90 = self.pulseCal.X90();
            self.gatedict.Xm90 = self.pulseCal.Xm90();
            self.gatedict.Y180 = self.pulseCal.Y180();
            self.gatedict.Ym180 = self.pulseCal.Ym180();
            self.gatedict.Y90 = self.pulseCal.Y90();
            self.gatedict.Ym90 = self.pulseCal.Ym90();
            
            if ~isempty(self.initGates) && ~iscell(self.initGates)
                    self.initGates = cellstr(self.initGates);
            end
            if ~isempty(self.repeatGates) && ~iscell(self.repeatGates)
                    self.repeatGates = cellstr(self.repeatGates);
            end
            if ~isempty(self.endGates) && ~iscell(self.endGates)
                    self.endGates = cellstr(self.endGates);
            end
            
            self.sequences = pulselib.gateSequence();
            for row = 1:length(self.repeatVector)
                self.sequences(row) = pulselib.gateSequence();
                for col = 1:length(self.initGates)
                    self.sequences(row).append(self.gatedict.(self.initGates{col}));
                end
                for repeat = 1:self.repeatVector(row)
                    for col = 1:length(self.repeatGates)
                        self.sequences(row).append(self.gatedict.(self.repeatGates{col}));
                    end
                end
                for col = 1:length(self.endGates)
                    self.sequences(row).append(self.gatedict.(self.endGates{col}));
                end
            end
            SetUp@explib.SweepM8195(self);
        end
    end
end