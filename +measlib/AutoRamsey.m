classdef AutoRamsey < measlib.SmartSweep
    % Echo experiment. Two qubit gates with varying delay and echo pulse in between.
    
    % 'qubitGates' is a cellstr that contains the names of gates
    % e.g., qubitGates = {'X90'}
    % 'delayVector' is an array that contains delay time between the gates
    % 'fringefreq' is the freq of the phase of last pi/2 pulse
    
    properties
        qubitGates = {'X90'};
        fringefreq=50e6;
        delayVector = linspace(0, 100e-9, 101);
    end
    
    methods
        function self = AutoRamsey(pulseCal, config)
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
            self.Normalize();
            figure(fignum);
            subplot(2, 1, 1);
            [freq,mse,amp,freqErr] = funclib.CosFit(self.result.rowAxis/1e-6, self.result.ampInt, self.fringefreq/1e6);
            self.result.AmpAmp=amp;
            self.result.Ampfreq=freq;
            self.result.AmpMSE=mse;
            self.result.AmpfreqErr=freqErr;
            if self.normalization
                ylabel('Normalized readout amplitude');
            else
                ylabel('Readout amplitude');
            end
            title(sprintf('Amplitude: Freq = %.3f \\pm %.3f MHz', freq,freqErr));
            axis tight;
            subplot(2, 1, 2);
            [freq,mse,amp,freqErr] = funclib.CosFit(self.result.rowAxis/1e-6, self.result.phaseInt, self.fringefreq/1e6);
            self.result.PhaseAmp=amp;  
            self.result.Phasefreq=freq;
            self.result.PhaseMSE=mse;
            self.result.PhasefreqErr=freqErr;
            if self.normalization
                ylabel('Normalized readout amplitude');
            else
                ylabel('Readout amplitude');
            end
            title(sprintf('Phase: Freq = %.3f \\pm %.3f MHz', freq,freqErr));
            xlabel('Delay (ns)');
            axis tight;
            if self.result.AmpMSE < self.result.PhaseMSE
                self.result.newFreq = self.pulseCal.qubitFreq + self.fringefreq ...
                                      - self.result.Ampfreq*1e6;
            else
                self.result.newFreq = self.pulseCal.qubitFreq + self.fringefreq ...
                                      - self.result.Phasefreq*1e6;
            end
        end
    end
end