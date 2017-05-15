classdef FreqCal < measlib.SmartSweep
    % Echo experiment. Two qubit gates with varying delay and echo pulse in between.
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X90'}
    % 'delayVector' is an array that contains delay time between the gates
    % 'fringefreq' is the frequency of artificial Ramsey fringes
    
    properties
        qubitGates = {'X90'};
        fringefreq = 50e6;
        delayVector = linspace(0, 100e-9, 101);
    end
    
    methods
        function self = FreqCal(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
        end
        
        function SetUp(self)
            % Construct pulse sequence
            startgates = pulselib.singleGate();
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
            
            % Vary azimuth angle of the last gates to introduce Ramsey-like fringes
            if self.fringefreq
                azimuthVector = linspace(0, 2*pi*self.fringefreq*self.delayVector(end), length(self.delayVector));
            else
                azimuthVector = zeros(1, length(self.delayVector));
            end
            % Construct sequences
            for row = 1:length(self.delayVector)
                % Append qubit gates
                self.gateseq(row) = pulselib.gateSequence(startgates);
                % Append  delay
                self.gateseq(row).append(pulselib.delay(self.delayVector(row)));
                % Append qubit gates again
                for col = 1:length(self.qubitGates)
                    endgates(col) = self.pulseCal.(self.qubitGates{col});
                    endgates(col).amplitude = endgates(col).amplitude;
                    endgates(col).azimuth = azimuthVector(row);
                end
                self.gateseq(row).append(endgates);
            end
            self.result.rowAxis = self.delayVector;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 105;
            end
            self.Integrate();
            
            figure(fignum);
            % Fit amplitude data
            if self.normalization
                self.Normalize();
                [t2,freq, mse, t2Err, freqErr] = ...
                    funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.normAmp);%,self.fringefreq/1e6);
                self.result.NormAmpt2Err = t2Err;
                self.result.NormAmpfreq = freq;
                self.result.NormAmpMSE = mse;
                self.result.NormAmpfreqErr = freqErr;
                self.result.NormAmpt2=t2;
                ylabel('Normalized readout');
                title(sprintf('t2=%.2f \\pm %.2f \\mu s | Freq = %.3f \\pm %.3f MHz', t2,t2Err,freq, freqErr));
                axis tight;
                self.result.newFreq = self.pulseCal.qubitFreq + self.fringefreq ...
                    - self.result.NormAmpfreq*1e6;
            else
                subplot(2, 1, 1);
                [t2,freq, mse, t2Err, freqErr] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.intI);
                ylabel('Readout I');
                title(sprintf('t2=%.2f \\pm %.2f \\mu s | Freq = %.3f \\pm %.3f MHz', t2,t2Err,freq, freqErr));
                xlabel('Delay (\mus)');
                self.result.It2Err = t2Err;
                self.result.Ifreq = freq;
                self.result.IMSE = mse;
                self.result.IfreqErr = freqErr;
                self.result.It2=t2;
                axis tight;
                %
                subplot(2, 1, 2);
                [t2,freq, mse, t2Err, freqErr] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.intQ);
                ylabel('Readout Q');
                title(sprintf('t2=%.2f \\pm %.2f \\mu s | Freq = %.3f \\pm %.3f MHz', t2,t2Err,freq, freqErr));
                xlabel('Delay (\mus)');
                axis tight;
                self.result.Qt2Err = t2Err;
                self.result.Qfreq = freq;
                self.result.QMSE = mse;
                self.result.QfreqErr = freqErr;
                self.result.Qt2=t2;
                % Choose I or Q by comparing their error
                if self.result.IMSE < self.result.QMSE
                    self.result.newFreq = self.pulseCal.qubitFreq + self.fringefreq ...
                        - self.result.Ifreq*1e6;
                else
                    self.result.newFreq = self.pulseCal.qubitFreq + self.fringefreq ...
                        - self.result.Qfreq*1e6;
                end
            end
            
            
            
        end
    end
end