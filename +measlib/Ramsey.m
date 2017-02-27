classdef Ramsey < measlib.SmartSweep
    % Ramsey experiment. Two qubit gates with varying delay in between.
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X90'}
    % 'delayVector' is an array that contains delay time between the gates
    
    properties
        qubitGates = {'X90'};
        delayVector = linspace(0, 20e-6, 101);
    end
    
    methods
        function self = Ramsey(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
        end
        
        function SetUp(self)
            % Construct qubit gates
            gates = pulselib.singleGate();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            for col = 1:length(self.qubitGates)
                gates(col) = self.pulseCal.(self.qubitGates{col});
            end
            % Construct sequences
            self.gateseq = pulselib.gateSequence();
            for row = 1:length(self.delayVector)
                % Append qubit gates
                self.gateseq(row) = pulselib.gateSequence(gates);
                % Append varying delay
                self.gateseq(row).append(pulselib.delay(self.delayVector(row)));
                % Append qubit gates again
                self.gateseq(row).append(gates);
            end
            self.result.rowAxis = self.delayVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 104;
            end
            self.Integrate();
            self.Normalize();
            figure(fignum);
            subplot(2, 1, 1);
            [t2, detuning] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.ampInt);
            if self.normalization
                ylabel('Normalized readout amplitude');
            else
                ylabel('Readout amplitude');
            end
            title(sprintf('T_2^* = %.2f \\mus, detuning = \\pm %.2f MHz', t2, detuning));
            axis tight;
            subplot(2, 1, 2);
                        [t2, detuning] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.phaseInt);
            if self.normalization
                ylabel('Normalized readout phase');
            else
                ylabel('Readout phase');
            end
            title(sprintf('T_2^* = %.2f \\mus, detuning = \\pm %.2f MHz', t2, detuning));
            xlabel('Delay (\mus)');
            axis tight;
        end
    end
end