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
            self.speccw = 0;
            self.rfcw = 0;
        end
        
        function SetUp(self)
            % Update params from pulseCal
            self.specfreq = self.pulseCal.qubitFreq;
            self.specpower = self.pulseCal.specPower;
            self.rffreq = self.pulseCal.cavityFreq;
            self.rfpower = self.pulseCal.rfPower;
            self.intfreq = self.pulseCal.intFreq;
            self.lopower = self.pulseCal.loPower;
            self.startBuffer = self.pulseCal.startBuffer;
            self.measBuffer = self.pulseCal.measBuffer;
            self.endBuffer = self.pulseCal.endBuffer;
            self.cardavg = self.pulseCal.cardAvg;
            self.carddelayoffset = self.pulseCal.cardDelayOffset;
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
            self.measpulse = self.pulseCal.measurement();
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
            piamp = funclib.RabiFit(self.result.rowAxis, self.result.ampI);
            ylabel('P(|1>)');
            xlabel('Amplitude');
            title(['\pi amplitude = ', num2str(piamp)]);
            axis tight;
        end
    end
end