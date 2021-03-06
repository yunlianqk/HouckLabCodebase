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
        end
        
        function SetUp(self)
            % Construct pulse sequence
            startgates = pulselib.singleGate();
            echogates = pulselib.singleGate();
            endgates = pulselib.singleGate();
            self.gateseq = pulselib.gateSequence();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            if ~isempty(self.echoGates) && ~iscell(self.echoGates)
                self.echoGates = cellstr(self.echoGates);
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
                % Append qubit gates, with varing azimuth
                for col = 1:length(self.qubitGates)
                    endgates(col) = self.pulseCal.(self.qubitGates{col});
                    endgates(col).amplitude = -endgates(col).amplitude;
                    endgates(col).azimuth = azimuthVector(row);
                end
                self.gateseq(row).append(endgates);
            end
            self.result.rowAxis = self.delayVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 104;
            end
            self.Integrate();
            
            figure(fignum);
            
            if self.normalization
                self.Normalize();
                [t2, freq, mse, t2Err, freqErr] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.normAmp);
                ylabel('Normalized readout');
                title(sprintf('t2=%.2f \\pm %.2f \\mu s | Freq = %.3f \\pm %.3f MHz', t2,t2Err,freq, freqErr));
                axis tight;
            else
                subplot(2, 1, 1);
                [t2, freq, mse, t2Err, freqErr] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.intI);
                ylabel('Readout I');
                title(sprintf('t2=%.2f \\pm %.2f \\mu s | Freq = %.3f \\pm %.3f MHz', t2,t2Err,freq, freqErr));
                xlabel('Delay (\mus)');
                
                axis tight;
                subplot(2, 1, 2);
                [t2, freq, mse, t2Err, freqErr] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.intQ);
                ylabel('Readout Q');
                title(sprintf('t2=%.2f \\pm %.2f \\mu s | Freq = %.3f \\pm %.3f MHz', t2,t2Err,freq, freqErr));
                xlabel('Delay (\mus)');
                axis tight;
                
            end


        end
    end
end