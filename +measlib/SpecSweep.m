classdef SpecSweep < measlib.SmartSweep
    % Spectroscopy measurement
    
    properties
        qubitGates = {};
    end    
    
    methods
        function self = SpecSweep(config)
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
            self.result.rowAxis = self.specfreq;
            if isa(self.pulseCal, 'paramlib.pulseCal')
                self.pulseCal.qubitFreq = self.specfreq;
            end
            SetUp@measlib.SmartSweep(self);
        end
       
        function Plot(self, fignum)
            if nargin == 1
                fignum = 112;
            end
            Plot@measlib.SmartSweep(self, fignum);

            subplot(2, 2, 2);
            plot(self.specfreq/1e9, self.result.ampInt);
            title('Amplitude');
            axis tight;
            subplot(2, 2, 4);
            plot(self.specfreq/1e9, self.result.phaseInt);
            axis tight;
            title('Phase');
            xlabel('Frequency (GHz)');
            axis tight;
            end
    end
end