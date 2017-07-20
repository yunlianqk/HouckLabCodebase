classdef TransSweep < measlib.SmartSweep
    % Transmission measureument
    
    properties
        qubitGates = {};
    end    
    
    methods
        function self = TransSweep(config)
            if nargin == 0
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.normalization = 0;
        end 

        function SetUp(self)
            if ~isempty(self.qubitGates)
                if isempty(self.pulseCal)
                    error('Needs pulseCal to generate qubitGates');
                end
                % Construct pulse sequence
                gates = pulselib.singleGate();
                if ~iscell(self.qubitGates)
                    self.qubitGates = cellstr(self.qubitGates);
                end
                for col = 1:length(self.qubitGates)
                    % Construct qubit gates
                    gates(col) = self.pulseCal.(self.qubitGates{col});
                end
                self.gateseq = pulselib.gateSequence(gates);
            end
            self.result.rowAxis = self.rffreq;
            if isa(self.pulseCal, 'paramlib.pulseCal')
                self.pulseCal.cavityFreq = self.rffreq;
            end
            SetUp@measlib.SmartSweep(self);
        end
       
        function Plot(self, fignum)
            self.Integrate();
            self.result.intAmp = sqrt(self.result.intI.^2 + self.result.intQ.^2);
            if nargin == 1
                fignum = 111;
            end
            figure(fignum);
            plot(self.rffreq/1e9, self.result.intAmp);
            xlabel('Frequency (GHz)');
            ylabel('Amplitude (V)');
            axis tight;
            end
    end
end