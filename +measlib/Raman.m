classdef Raman < measlib.SmartSweep
    % Spectroscopy measurement
    
    properties
        qubitGates = {};
        qubitGates2 = {};
    end    
    
    methods
        function self = Raman(pulseCal,pulseCal2,config)
            if nargin == 0
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.normalization = 0;
            self.pulseCal = pulseCal;
            self.pulseCal2 = pulseCal2;
        end 

        function SetUp(self)
            
            % Construct sequences
            self.gateseq = pulselib.gateSequence();
            self.gateseq2 = pulselib.gateSequence();
            
            if ismember(self.qubitGates,{'rectPulse'})
                gates = pulselib.measPulse();
                gates2 = pulselib.measPulse();
            else
                gates = pulselib.singleGate();
                gates2 = pulselib.singleGate();
            end

            for col = 1:length(self.qubitGates)
                % Construct qubit gates
                gates(col) = self.pulseCal.(self.qubitGates{col});
            end
            self.gateseq = pulselib.gateSequence(gates);
            
            for col = 1:length(self.qubitGates2)
                % Construct qubit gates
                gates2(col) = self.pulseCal2.(self.qubitGates2{col});
            end
            self.gateseq2 = pulselib.gateSequence(gates2);
                     
            SetUp@measlib.SmartSweep(self);
        end
       
        function Plot(self, fignum)
            self.Integrate();
            self.result.intAmp = sqrt(self.result.intI.^2 + self.result.intQ.^2);
            self.result.intPhase = atan2(self.result.intQ, self.result.intI);
            if nargin == 1
                fignum = 112;
            end
            figure(fignum);
            subplot(2, 1, 1);
            plot(self.spec2freq/1e9, self.result.intAmp);
            title('Amplitude');
            axis tight;
            subplot(2, 1, 2);
            plot(self.spec2freq/1e9, self.result.intPhase);
            title('Phase');
            xlabel('Frequency (GHz)');
            axis tight;
            end
    end
end