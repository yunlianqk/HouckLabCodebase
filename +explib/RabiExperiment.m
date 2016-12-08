classdef RabiExperiment < explib.SweepM8195
    % Rabi Experiment. Qubit gates with varying amplitude.
   
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X180'} or qubitGates = {'X90', 'X90'}, etc.
    % 'ampVector' is an array that contains the amplitudes in the sweep
    % the amplitude values should be between 0 and 1

    properties
        qubitGates = {'X180'};
        ampVector = linspace(0, 1, 51); % amplitude for qubit gates
    end
    
    methods
        function self = RabiExperiment(pulseCal, config)
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
            self.Plot();
        end
        
        function Plot(self)
            figure(188);
            self.result.newAmp = funclib.RabiFit2(self.ampVector, self.result.AmpInt);
            xlabel('Drag amplitude');
            ylabel('Readout amplitude');
            title([self.experimentName, ', new amplitude: ', num2str(self.result.newAmp)]);
        end
    end
end