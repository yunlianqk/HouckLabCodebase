classdef CrossResonance < measlib.SmartSweep
    
    properties
        durationVector = linspace(0, 5e6, 101);
        amplitude = 1;
        sigma = 10e-9;
        cutoff = 30e-9;
        controlfreq;
        controlstate = 0;
        targetfreq;
        echo = 0;
    end
    
    methods
        function self = CrossResonance(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
        end
        
        function SetUp(self)
            % Construct gate objects on control qubit
            X180 = self.pulseCal.X180();
            Id = self.pulseCal.Identity();
            % Construct sequences
            self.gateseq = pulselib.gateSequence();
            self.fluxseq = pulselib.gateSequence();
            for row = 1:length(self.durationVector)
                if ~self.echo
                    % Simple CR gate
                    % Contruct CR pulse
                    duration = self.durationVector(row);
                    if duration <= self.sigma*sqrt(2*pi)
                        % Use gaussian pulse for short CR
                        CR = pulselib.singleGate('X180');
                        CR.amplitude = self.amplitude*duration/(self.sigma*sqrt(2*pi));
                    else
                        % Use rectangular pulse + gaussian edges for long CR
                        duration = duration - self.sigma*sqrt(2*pi);
                        CR = pulselib.measPulse(duration);
                        CR.amplitude = self.amplitude;
                    end
                    CR.sigma = self.sigma;
                    CR.cutoff = self.cutoff;
                    CR.buffer = self.pulseCal.buffer;
                    % Pulse sequence on target qubit
                    self.fluxseq(row) = pulselib.gateSequence(Id);
                    self.fluxseq(row).append(CR);
                    self.fluxseq(row).append(Id);
                    % Pulse sequence on control qubit
                    if self.controlstate == 0
                        self.gateseq(row) = pulselib.gateSequence(Id);
                        self.gateseq(row).append(pulselib.delay(CR.totalDuration));
                        self.gateseq(row).append(Id);
                    else
                        self.gateseq(row) = pulselib.gateSequence(X180);
                        self.gateseq(row).append(pulselib.delay(CR.totalDuration));
                        self.gateseq(row).append(X180);
                    end
                else
                    % Echoed CR gate
                    duration = self.durationVector(row)/2;
                    % CR pulse is split into two with positive and nagative amplitude
                    if duration <= self.sigma*sqrt(2*pi)
                        % Use gaussian pulse for short CR
                        CRp = pulselib.singleGate('X180');
                        CRp.amplitude = self.amplitude*duration/(self.sigma*sqrt(2*pi));
                        CRm = pulselib.singleGate('X180');
                        CRm.amplitude = -self.amplitude*duration/(self.sigma*sqrt(2*pi));
                    else
                        % Use rectangular pulse + gaussian edges for long CR
                        duration = duration - self.sigma*sqrt(2*pi);
                        CRp = pulselib.measPulse(duration);
                        CRp.amplitude = self.amplitude;
                        CRm = pulselib.measPulse(duration);
                        CRm.amplitude = -self.amplitude;
                    end
                    CRp.sigma = self.sigma;
                    CRm.sigma = self.sigma;
                    CRp.cutoff = self.cutoff;
                    CRm.cutoff = self.cutoff;
                    CRp.buffer = self.pulseCal.buffer;
                    CRm.buffer = self.pulseCal.buffer;
                    % Pulse sequence on target qubit
                    self.fluxseq(row) = pulselib.gateSequence(Id);
                    self.fluxseq(row).append(CRp);
                    self.fluxseq(row).append(Id);
                    self.fluxseq(row).append(CRm);
                    self.fluxseq(row).append(Id);
                    % Pulse sequence on control qubit
                    delaygate = pulselib.delay(CRp.totalDuration);
                    if self.controlstate == 0
                        self.gateseq(row) = pulselib.gateSequence(Id);
                        self.gateseq(row).append(delaygate);
                        self.gateseq(row).append(Id);%(X180);
                        self.gateseq(row).append(delaygate);
                        self.gateseq(row).append(Id);%(X180);
                    else
                        self.gateseq(row) = pulselib.gateSequence(X180);
                        self.gateseq(row).append(delaygate);
                        self.gateseq(row).append(X180);
                        self.gateseq(row).append(delaygate);
                        self.gateseq(row).append(Id);
                    end
                end
            end
            self.result.rowAxis = self.durationVector;
            self.specfreq = self.controlfreq;
            self.spec2freq = self.targetfreq;
            SetUp@measlib.SmartSweep(self);
        end
        
        function Fit(self, fignum)
            if nargin == 1
                fignum = 104;
            end
            self.Integrate();
            self.Normalize();
            figure(fignum);
            subplot(2, 1, 1);
            
            [t2, detuning,mse,t2Err,detuningErr] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.ampInt);
            self.result.Ampt2=t2;
            self.result.Ampfreq=detuning;
            self.result.AmpMSE=mse;
            self.result.Ampt2Err=t2Err;
            self.result.AmpfreqErr=detuningErr;
            if self.normalization
                ylabel('Normalized readout amplitude');
            else
                ylabel('Readout amplitude');
            end

            title(sprintf('T_2^* = %.2f \\pm %.2f \\mus, detuning =  %.2f MHz \\pm %.2f MHz', t2,t2Err, detuning,detuningErr));
            axis tight;
            subplot(2, 1, 2);
            
            [t2, detuning,mse,t2Err,detuningErr] = funclib.ExpCosFit(self.result.rowAxis/1e-6, self.result.phaseInt);
            self.result.Phaset2=t2;
            self.result.Phasefreq=detuning;
            self.result.PhaseMSE=mse;
            self.result.Phaset2Err=t2Err;
            self.result.PhasefreqErr=detuningErr;
            if self.normalization
                ylabel('Normalized readout phase');
            else
                ylabel('Readout phase');
            end
            title(sprintf('T_2^* = %.2f \\pm %.2f \\mus, detuning = %.2f MHz \\pm %.2f MHz', t2, t2Err,detuning,detuningErr));
            xlabel('Delay (\mus)');
            axis tight;
        end
        
    end
end