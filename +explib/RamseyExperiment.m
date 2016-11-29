classdef RamseyExperiment < explib.SweepM8195
    % Ramsey experiment. Two qubit gates with varying delay in between.
    
    properties 
        qubitGates = {'X90'};
        delayVector = linspace(0, 1.2e-6, 101); % delay btw qubit gates
    end
    
    methods
        function self = RamseyExperiment(pulseCal)
            self = self@explib.SweepM8195(pulseCal);
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
                gates(col) = pulselib.singleGate(self.qubitGates{col}, self.pulseCal);
            end
            % Construct sequences
            for row = 1:length(self.delayVector)
                % Append qubit gates
                self.sequences(row) = pulselib.gateSequence(gates);
                % Append varying delay
                self.sequences(row).append(pulselib.delay(self.delayVector(row)));
                % Append qubit gates again
                self.sequences(row).extend(gates);
            end
            SetUp@explib.SweepM8195(self);
        end
    end
end
       
        
        
        