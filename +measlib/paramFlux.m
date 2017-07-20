classdef paramFlux < measlib.SmartSweep
    properties
        qubitGates = {'X180'};
        ampVector = 1;
        fluxduration = 5e-6;
        fluxamp = 1.0;
        fluxbuffer = 50e-9;
    end
    
    methods
        function self = paramFlux(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;     
        end
        
        function SetUp(self)
            % Construct pulse sequence
            gates = pulselib.singleGate();
            self.gateseq = pulselib.gateSequence();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            for row = 1:length(self.ampVector)
                for col = 1:length(self.qubitGates)
                    % Construct qubit gates
                    gates(col) = self.pulseCal.(self.qubitGates{col});
                    % Keep original drag ratio
                    gates(col).dragAmplitude ...
                        = gates(col).dragAmplitude/gates(col).amplitude*self.ampVector(row);
                    % Vary amplitude
                    gates(col).amplitude = self.ampVector(row);
                end
                % Construct sequences
                self.gateseq(row) = pulselib.gateSequence(gates);
                % Append delay before flux pulse is truned off
                self.gateseq(row).append(pulselib.delay(self.fluxbuffer));
            end
            
            % Define rectangular pulse for flux drive
            fluxseq = pulselib.gateSequence();
            fluxpulse = pulselib.measPulse(self.fluxduration, self.fluxamp);
            fluxseq.append(fluxpulse);
            self.fluxseq = [self.fluxseq, fluxseq];

            self.result.rowAxis = self.ampVector;
            SetUp@measlib.SmartSweep(self);
        end
        
    end
end