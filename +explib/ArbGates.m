classdef ArbGates < explib.SweepM8195
    % Running arbitrary sequences of single qubit gates.
    
    % qubitGates is a cell array of cellstr's that contain the names of gates
    % Each element of the array specifies one sequence
    % Example:
    % qubitGates = {{'X180'}, ...
    %               {'X90', 'Y90'}, ...
    %               {'Identity'}};

    % All primary gates are stored in self.gatedict and can be accessed by
    % self.gatedict.(name), e.g. self.gatedic.('X180') returns the X180 gate
    
    properties 
        qubitGates;
    end
    
    properties (SetAccess = private)
        gatedict;
    end
    
    methods
        function self = ArbGates(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.SweepM8195(pulseCal, config);
            self.histogram = 0;
        end

        function SetUp(self)
            % Construct and store primary gates
            self.gatedict.Identity = self.pulseCal.Identity();
            self.gatedict.X180 = self.pulseCal.X180();
            self.gatedict.X90 = self.pulseCal.X90();
            self.gatedict.Xm90 = self.pulseCal.Xm90();
            self.gatedict.Y180 = self.pulseCal.Y180();
            self.gatedict.Y90 = self.pulseCal.Y90();
            self.gatedict.Ym90 = self.pulseCal.Ym90();
            
            self.sequences = pulselib.gateSequence();
            for row = 1:length(self.qubitGates)
                gates = self.qubitGates{row};
                if ~isempty(gates) && ~iscell(gates)
                    gates = cellstr(gates);
                end
                self.sequences(row) = pulselib.gateSequence();
                for col = 1:length(gates)
                    self.sequences(row).append(self.gatedict.(gates{col}));
                end
            end
            SetUp@explib.SweepM8195(self);
        end
    end
end