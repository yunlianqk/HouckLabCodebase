classdef RabiSigma < measlib.SmartSweep
    % Rabi Experiment. Qubit gates with varying amplitude.
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X180'} or qubitGates = {'X90', 'X90'}, etc.
    % 'ampVector' is an array that contains the amplitudes in the sweep
    % the values in 'ampVector' should be between 0 and 1
    
    properties
        qubitGates = {'X180'};
        ampVector = ones(1,101);%linspace(0, 1, 101);
        sigmaVector=linspace(0.2e-6,2e-6,101);
    end
    
    methods
        function self = RabiSigma(pulseCal, config)
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
                    % Vary sigma
                    gates(col).amplitude = self.ampVector(row);
                    gates(col).sigma=self.sigmaVector(row);
                end
                % Construct sequences
                self.gateseq(row) = pulselib.gateSequence(gates);
            end
            
            self.result.rowAxis = self.ampVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function [piamp,piamp_phase] = Fit(self, fignum)
            if nargin == 1
                fignum = 102;
            end
            self.Integrate();
            self.Normalize();
            figure(fignum);
            subplot(2, 1, 1);
            try
                piamp = funclib.RabiFit(self.result.rowAxis, self.result.ampInt);
            catch 
                piamp = 1;
            end
            if self.normalization
                ylabel('Normalized readout amplitude');
            else
                ylabel('Readout amplitude');
            end
            title(['\pi sigma = ', num2str(piamp)]);
            axis tight;
            subplot(2, 1, 2);
            try
                piamp_phase = funclib.RabiFit(self.result.rowAxis, self.result.phaseInt);
            catch
                piamp_phase = 1;
            end
            if self.normalization
                ylabel('Normalized readout phase');
            else
                ylabel('Readout phase');
            end
            xlabel('Drive amplitude');
            title(['\pi amplitude = ', num2str(piamp_phase)]);
            axis tight;
        end
    end
end