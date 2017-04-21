classdef CrossAutoRamsey < measlib.SmartSweep
    
    properties
        qubitGates = {'X90'};
        fringefreq=50e6;
        delayVector = linspace(0, 100e-9, 101);
        pulseCal2;
    end
    
    methods
        function self = CrossAutoRamsey(pulseCal, pulseCal2, config)
            if nargin == 2
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.pulseCal2 = pulseCal2;
        end
        
        function SetUp(self)
            % Update params from pulseCal
            % PulseCal is target and PulseCal2 is control
            self.specfreq = self.pulseCal.qubitFreq;
            self.specpower = self.pulseCal.specPower;
            self.spec2freq = self.pulseCal2.qubitFreq;
            self.spec2power = self.pulseCal2.specPower;
            self.rffreq = self.pulseCal.cavityFreq;
            self.rfpower = self.pulseCal.rfPower;
            self.intfreq = self.pulseCal.intFreq;
            self.lopower = self.pulseCal.loPower;
            self.startBuffer = self.pulseCal.startBuffer;
            self.measBuffer = self.pulseCal.measBuffer;
            self.endBuffer = self.pulseCal.endBuffer;
            self.cardavg = self.pulseCal.cardAvg;
            self.carddelayoffset = self.pulseCal.cardDelayOffset;
            % Construct qubit gates
            X180 = self.pulseCal2.X180();
            Id = self.pulseCal.Identity();
            % Construct qubit gates
            startgates = pulselib.singleGate();
            endgates = pulselib.singleGate();
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
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
            self.gateseq = pulselib.gateSequence();
            self.fluxseq = pulselib.gateSequence();
            for row = 1:length(self.delayVector)
                delay = self.delayVector(row);
                % Start qubit gates
                %self.gateseq(row) = pulselib.gateSequence(Id); % what is the purpose of this gate?
                self.gateseq(row) = pulselib.gateSequence(startgates);
                % Append delay
                self.gateseq(row).append(pulselib.delay(delay));
                %self.gateseq(row).append(startgates);
                %self.gateseq(row).append(Id);
                
                % Append qubit gates again
                for col = 1:length(self.qubitGates)
                    endgates(col) = self.pulseCal.(self.qubitGates{col});
                    endgates(col).amplitude = endgates(col).amplitude;
                    endgates(col).azimuth = azimuthVector(row);
                end
                self.gateseq(row).append(endgates);
                self.gateseq(row).append(Id);
                
                self.fluxseq(row) = pulselib.gateSequence(X180);
                self.fluxseq(row).append(pulselib.delay(delay+sum(startgates.totalDuration)+sum(endgates.totalDuration))); %is this correct?
                self.fluxseq(row).append(X180);
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