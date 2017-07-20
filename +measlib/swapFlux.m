classdef swapFlux < measlib.SmartSweep
    properties
        qubitGates = {'X180'};
        fluxduration = linspace(0,0.2e-6,101);
        fluxamp = 1.0;
        fluxbuffer = 25e-9;
        fluxsigma = 10e-9;
    end
    
    methods
        function self = swapFlux(pulseCal, config)
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
            
            for row = 1:length(self.fluxduration)
                for col = 1:length(self.qubitGates)
                    % Construct qubit gates
                    gates(col) = self.pulseCal.(self.qubitGates{col});
                end
                % Define flux drive as rectangular pulse with varying duration
                fluxseq = pulselib.gateSequence();
                fluxpulse = pulselib.measPulse(self.fluxduration(row), self.fluxamp,0, self.fluxsigma);
                fluxseq.append(fluxpulse);
                self.fluxseq = [self.fluxseq, fluxseq];
                
                % Construct sequences for rabi pulse+delay
                self.gateseq(row) = pulselib.gateSequence(gates);
                self.gateseq(row).append(pulselib.delay(fluxpulse.totalDuration+self.fluxbuffer));
            end

            self.result.rowAxis = self.fluxduration;
            SetUp@measlib.SmartSweep(self);
        end
        
    end
end