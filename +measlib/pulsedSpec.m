classdef pulsedSpec < measlib.SmartSweep
    % Pulsed Transmission. Vary measurement pulse frequency
    
    % 'specfreqVector' is an array that contains the spec freq in the sweep
    
    properties
        specfreqVector = linspace(5e9,6e9,101);
    end
    
    methods
        function self = pulsedSpec(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.rfcw = 0; % RFgen in pulsed mode
            self.speccw = 0; % Specgen in pulsed mode
            self.normalization = 0;
            self.UpdateParams();
        end
        
        function UpdateParams(self)
            % Update params from properties
            self.specfreq = self.specfreqVector;
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
            
            % Define qubit drive
            gates = pulselib.gateSequence();
            qubitPulse = self.pulseCal.X180();
            gates.append(qubitPulse);
            self.gateseq = gates;
            % Measurement pulse
            self.measpulse = self.pulseCal.measurement();
            self.result.rowAxis = self.specfreq;
        end
        
        function SetUp(self)
            self.UpdateParams();
            SetUp@measlib.SmartSweep(self);
        end
    end
end