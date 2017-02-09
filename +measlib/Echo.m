classdef Echo < measlib.SmartSweep
    % Echo experiment. Two qubit gates with varying delay and echo pulse in between.
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X90'}
    % 'delayVector' is an array that contains delay time between the gates
    % 'numfringes' is an integer that adds intentional Ramsey-like fringes
    
    properties
        qubitGates = {'X90'};
        echoGates = {'X180'};
        numfringes = 0;
        delayVector = linspace(0, 20e-6, 101);
    end
    
    methods
        function self = Echo(pulseCal, config)
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
            startgates = pulselib.singleGate();
            echogates = pulselib.singleGate();
            endgates = pulselib.singleGate();
            self.gateseq = pulselib.gateSequence();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.endGates = cellstr(self.endGates);
            end
            % Construct qubit gates
            for col = 1:length(self.qubitGates)
                startgates(col) = self.pulseCal.(self.qubitGates{col});
            end
            for col = 1:length(self.echoGates)
                echogates(col) = self.pulseCal.(self.echoGates{col});
            end
            % Vary azimuth angle of the last gates to introduce Ramsey-like fringes
            if self.numfringes
                azimuthVector = linspace(0, 2*pi*self.numfringes, length(self.delayVector));
            else
                azimuthVector = zeros(1, length(self.delayVector));
            end
            % Construct sequences
            for row = 1:length(self.delayVector)
                % Append qubit gates
                self.gateseq(row) = pulselib.gateSequence(startgates);
                % Append half delay
                self.gateseq(row).append(pulselib.delay(self.delayVector(row)/2));
                % Append echo gate
                self.gateseq(row).append(echogates);
                % Append half delay again
                self.gateseq(row).append(pulselib.delay(self.delayVector(row)/2));
                % Append qubit gates again
                for col = 1:length(self.qubitGates)
                    endgates(col) = self.pulseCal.(self.qubitGates{col});
                    endgates(col).amplitude = -endgates(col).amplitude;
                    endgates(col).azimuth = azimuthVector(row);
                end
                self.gateseq(row).append(endgates);
            end
            self.measpulse = self.pulseCal.measurement();
            self.result.rowAxis = self.delayVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 104;
            end
            self.Integrate();
            self.Normalize();
            figure(fignum);
            if self.numfringes
                [t2, ~] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.ampI);
            else
                fitresult = funclib.ExpFit(self.result.rowAxis/1e-6, self.result.ampI);
                t2 = fitresult.lambda;
            end
            ylabel('P(|1>)');
            xlabel('Delay (\mus)');
            title(sprintf('T_2^E = %.2f \\mus', t2));
            axis tight;
        end
    end
end