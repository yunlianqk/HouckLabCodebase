classdef T1 < measlib.SmartSweep
    % T1 Experiment. Qubit gates with varying delay.
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X180'} or qubitGates = {'Y180'}, etc.
    % 'delayVector' is an array that contains the delay time following the gate
    
    properties
        qubitGates = {'X180'};
        delayVector = linspace(0, 20e-6, 101);
    end
    
    methods
        function self = T1(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;     
        end
        
        function SetUp(self)
            % Construct gates
            gates = pulselib.singleGate();
            self.gateseq = pulselib.gateSequence();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            for col = 1:length(self.qubitGates)
                gates(col) = self.pulseCal.(self.qubitGates{col});
            end
            % Construct sequences
            for row = 1:length(self.delayVector)
                % Append qubit gates
                self.gateseq(row) = pulselib.gateSequence(gates);
                % Append varying delay
                self.gateseq(row).append(pulselib.delay(self.delayVector(row)));
            end
            self.result.rowAxis = self.delayVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 103;
            end
            self.Integrate();
            figure(fignum);
            if self.normalization
                self.Normalize();
                fitresult = funclib.ExpFit(self.result.rowAxis/1e-6, ...
                                           self.result.normAmp);
                t1 = fitresult.lambda;
                xlabel('Delay (\mus)');
                ylabel('Normalized readout');
                title(['T_1 = ', num2str(t1), ' \mus']);
                axis tight;
            else
                subplot(2, 1, 1);
                fitresult = funclib.ExpFit(self.result.rowAxis/1e-6, ...
                                           self.result.intI);
                t1 = fitresult.lambda;
                ylabel('Readout I');
                title(['T_1 = ', num2str(t1), ' \mus']);
                axis tight;
                subplot(2, 1, 2);
                fitresult = funclib.ExpFit(self.result.rowAxis/1e-6, ...
                                           self.result.intQ);
                t1 = fitresult.lambda;
                xlabel('Delay (\mus)');
                ylabel('Readout Q');
                title(['T_1 = ', num2str(t1), ' \mus']);
                axis tight;
            end
        end
    end
end