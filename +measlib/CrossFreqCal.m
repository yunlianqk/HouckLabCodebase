classdef CrossFreqCal < measlib.SmartSweep
    
    properties
        qubitGates = {'X90'};
        fringefreq=50e6;
        delayVector = linspace(0, 100e-9, 101);
    end
    
    methods
        function self = CrossFreqCal(pulseCal, pulseCal2, config)
            if nargin == 2
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.pulseCal2 = pulseCal2;
        end
        
        function SetUp(self)
            % Turn off DRAG when calibrating frequency
            self.pulseCal.([self.qubitGates{1}, 'DragAmplitude']) = 0;
            % Construct qubit gates
            X180 = self.pulseCal2.X180();
            Id = self.pulseCal2.Identity();
            startgates = pulselib.singleGate();
            endgates = pulselib.singleGate();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            for col = 1:length(self.qubitGates)
                startgates(col) = self.pulseCal.(self.qubitGates{col});
            end
            % Construct sequences
            self.gateseq = pulselib.gateSequence();
            self.gateseq2 = pulselib.gateSequence();
            for row = 1:length(self.delayVector)
                delay = self.delayVector(row);
                % Qubit 1 (target) sequence
                % Append start gates
                self.gateseq(row) = pulselib.gateSequence(startgates);
                % Append delay
                self.gateseq(row).append(pulselib.delay(delay));
                % Append end gates with varying azimuth
                for col = 1:length(self.qubitGates)
                    endgates(col) = self.pulseCal.(self.qubitGates{col});
                    endgates(col).azimuth = 2*pi*self.fringefreq*self.delayVector(row);
                end
                self.gateseq(row).append(endgates);
                % Append pulseCal2.Identity to make timing correct
                self.gateseq(row).append(Id);
                % Qubit 2 (control) sequence
                % Append pi pulse
                self.gateseq2(row) = pulselib.gateSequence(X180);
                % Append delay + duration of (start gates + end gates)
                self.gateseq2(row).append(pulselib.delay(delay + ...
                                                         sum(startgates.totalDuration) + ...
                                                         sum(endgates.totalDuration)));
                % Append pi pulse
                self.gateseq2(row).append(X180);
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