classdef RamseyExperiment < explib.SweepM8195
    % Ramsey experiment. Two qubit gates with varying delay in between.
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X90'}
    % 'delayVector' is an array that contains delay time between the gates
    
    properties 
        qubitGates = {'X90'};
        delayVector = linspace(0, 1.2e-6, 101); % delay btw qubit gates
    end
    
    methods
        function self = RamseyExperiment(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.SweepM8195(pulseCal, config);
            self.histogram = 0;
        end

        function SetUp(self)
            gates = pulselib.singleGate();
            self.sequences = pulselib.gateSequence();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            % Construct qubit gates
            for col = 1:length(self.qubitGates)
                gates(col) = self.pulseCal.(self.qubitGates{col});
            end
            % Construct sequences
            for row = 1:length(self.delayVector)
                % Append qubit gates
                self.sequences(row) = pulselib.gateSequence(gates);
                % Append varying delay
                self.sequences(row).append(pulselib.delay(self.delayVector(row)));
                % Append qubit gates again
                self.sequences(row).append(gates);
            end
            SetUp@explib.SweepM8195(self);
        end
    end
end
       
        
        
        