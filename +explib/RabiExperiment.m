classdef RabiExperiment < explib.SweepM8195
    % Rabi Experiment. Qubit gates with varying amplitude.

    properties
        qubitGates = {'X180'};
        ampVector = linspace(0, 1, 51); % amplitude for qubit gates
    end
    
    methods
        function self = RabiExperiment(pulseCal)
            self = self@explib.SweepM8195(pulseCal);
            self.histogram = 0;
        end
        
        function SetUp(self)
            gates = pulselib.singleGate();
            self.sequences = pulselib.gateSequence();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            
            for row = 1:length(self.ampVector)
                for col = 1:length(self.qubitGates)
                    % Construct qubit gates
                    gates(col) = pulselib.singleGate(self.qubitGates{col}, self.pulseCal);
                    % Keep original drag ratio
                    gates(col).dragAmplitude ...
                        = gates(col).dragAmplitude/gates(col).amplitude*self.ampVector(row);
                    % Vary amplitude
                    gates(col).amplitude = self.ampVector(row);
                end
                % Construct sequences
                self.sequences(row) = pulselib.gateSequence(gates);
            end
            SetUp@explib.SweepM8195(self);
        end
        
        function Run(self)
            Run@explib.SweepM8195(self);
            figure(188);
            self.result.newAmp = funclib.RabiFit2(self.ampVector, self.result.AmpInt);
            xlabel('Drag amplitude');
            ylabel('Readout amplitude');
            title([self.experimentName, ', new amplitude: ', num2str(self.result.newAmp)]);
        end
    end
end