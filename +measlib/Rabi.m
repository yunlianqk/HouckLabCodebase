classdef Rabi < measlib.SmartSweep
    % Rabi Experiment. Qubit gates with varying amplitude.
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X180'} or qubitGates = {'X90', 'X90'}, etc.
    % 'ampVector' is an array that contains the amplitudes in the sweep
    % the values in 'ampVector' should be between 0 and 1
    
    properties
        qubitGates = {'X180'};
        ampVector = linspace(0, 1, 101);
    end
    
    methods
        function self = Rabi(pulseCal, config)
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
            end
            
            self.result.rowAxis = self.ampVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 102;
            end
            self.Integrate();
            self.Normalize();
            figure(fignum);
            subplot(2, 1, 1);
            piamp = funclib.RabiFit(self.result.rowAxis, self.result.ampInt);
            if self.normalization
                ylabel('Normalized readout amplitude');
            else
                ylabel('Readout amplitude');
            end
            title(['\pi amplitude = ', num2str(piamp)]);
            axis tight;
            subplot(2, 1, 2);
            piamp = funclib.RabiFit(self.result.rowAxis, self.result.phaseInt);
            if self.normalization
                ylabel('Normalized readout phase');
            else
                ylabel('Readout phase');
            end
            xlabel('Drive amplitude');
            title(['\pi amplitude = ', num2str(piamp)]);
            axis tight;
        end
    end
end