classdef T1Experiment < explib.SweepM8195
    % T1 Experiment. Qubit gates with varying delay.

    properties
        qubitGates = {'X180'};
        delayVector = linspace(0, 100e-6, 101); % delay btw qubit gates and measurement pulse
    end
    
    methods
        function self = T1Experiment(pulseCal)
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
            end
            SetUp@explib.SweepM8195(self);
        end
        
        function Run(self)
            Run@explib.SweepM8195(self);
            self.Plot();
        end
        
        function Plot(self)
            figure(101);
            fitResults = funclib.ExpFit3(self.delayVector/1e-6, self.result.AmpInt);
            self.result.T1 = fitResults.lambda;
            xlabel('Delay (\mus)');
            ylabel('Amplitude');
            title(['T_1 = ', num2str(self.result.T1), ' \mus']);
            save('D:\Gengyan\test.mat', 'self');
        end
    end
end
       