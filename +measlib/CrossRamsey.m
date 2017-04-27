classdef CrossRamsey < measlib.SmartSweep
    
    properties
        qubitGates = {'X90'};
        delayVector = linspace(0, 2e6, 51);
        pulseCal2;
    end
    
    methods
        function self = CrossRamsey(pulseCal, pulseCal2, config)
            if nargin == 2
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.pulseCal2 = pulseCal2;
        end
        
        function SetUp(self)
            % Update params from pulseCal
            self.specfreq = self.pulseCal.qubitFreq;
            self.specpower = self.pulseCal.specPower;
            self.spec2freq = self.pulseCal2.qubitFreq;
            self.spec2power = self.pulseCal2.specPower;
            self.rffreq = self.pulseCal.cavityFreq;
            self.rfpower = self.pulseCal.rfPower;
            self.intfreq = self.pulseCal.intFreq;
            self.lopower = self.pulseCal.loPower;
            self.startBuffer = self.pulseCal.startBuffer;
            self.measBuffer = self.pulseCal.measBuffer;
            self.endBuffer = self.pulseCal.endBuffer;
            self.cardavg = self.pulseCal.cardAvg;
            self.carddelayoffset = self.pulseCal.cardDelayOffset;
            % Construct qubit gates
            X180 = self.pulseCal2.X180();
            Id = self.pulseCal.Identity();
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
            self.fluxseq = pulselib.gateSequence();
            for row = 1:length(self.delayVector)
                delay = self.delayVector(row);
                self.gateseq(row) = pulselib.gateSequence(Id);
                self.gateseq(row) = pulselib.gateSequence(gates);
                self.gateseq(row).append(pulselib.delay(delay));
                self.gateseq(row).append(gates);
                self.gateseq(row).append(Id);
                
                self.fluxseq(row) = pulselib.gateSequence(X180);
                
                self.fluxseq(row).append(pulselib.delay(delay+2*sum(gates.totalDuration)));
                self.fluxseq(row).append(X180);
            end
            self.result.rowAxis = self.delayVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 103;
            end
            self.Integrate();
            self.Normalize();
            figure(fignum);
            [t2, detuning] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.ampInt);
            ylabel('P(|1>)');
            xlabel('Delay (\mus)');
            title(sprintf('T_2^* = %.2f \\mus, detuning = \\pm %.2f MHz', t2, detuning));
            axis tight;
        end
    end
end