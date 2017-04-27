classdef paramFlux < measlib.SmartSweep
    % Generic flux pump experiment
    
    
    properties
        fluxFreq = 2.0788e9;
        fluxAmp = 1.0
        fluxDuration = 5e-6;
        
        specFreq = 4.0749e9;
        specAmp = linspace(0,1,101);
        specbuffer = 200e-9; % buffer between the end of spec pulse and the end of the flux pulse
    end
    
    methods
        function self = paramFlux(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.rfcw = 0; % RFgen in pulsed mode
            self.speccw = 0; % Specgen in pulsed mode
            self.fluxcw = 0; % Fluxgen in pulsed mode
            self.rffreq = self.pulseCal.cavityFreq;
            self.normalization = 0;
            self.UpdateParams();
        end
        
        function UpdateParams(self)
            % Update params from properties
            self.specfreq = self.specFreq;
            self.fluxfreq = self.fluxFreq;
            % Update params from pulseCal
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
            
            self.gateseq = [];
            self.fluxseq = [];
            
            % Define rectangular pulse as parametric flux drive
            fluxseq = pulselib.gateSequence();
            fluxpulse = pulselib.measPulse(self.fluxDuration,self.fluxAmp);
            fluxseq.append(fluxpulse);
            self.fluxseq = [self.fluxseq, fluxseq];
            
            % Define rectangular pulse with gaussian tail as gate pulse
            % with varying amplitude
            for row =1:length(self.specAmp)
                gateseq = pulselib.gateSequence();
%                 self.pulseCal.rectPulseAmp = self.specAmp(row);
                gate = self.pulseCal.X180();
                gate.amplitude = self.specAmp(row);
                gateseq.append(gate);
                gateseq.append(pulselib.delay(self.specbuffer));
                self.gateseq = [self.gateseq gateseq];
            end
            
            
            
            % Measurement pulse
            self.measpulse = self.pulseCal.measurement();
        end
        
        function SetUp(self)
            self.UpdateParams();
            SetUp@measlib.SmartSweep(self);
        end
    end
end