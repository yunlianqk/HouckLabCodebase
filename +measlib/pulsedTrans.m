classdef pulsedTrans < measlib.SmartSweep
    % Pulsed Transmission. Vary measurement pulse frequency
    
    % 'rffreqVector' is an array that contains the RF freq in the sweep
    
    properties
        rffreqVector = linspace(5e9,6e9,101);
    end
    
    methods
        function self = pulsedTrans(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.rfcw = 0; % RFgen in pulsed mode
            self.normalization = 0;
            self.UpdateParams();
        end
        
        function UpdateParams(self)
            % Update params from properties
            self.rffreq = self.rffreqVector;
            % Update params from pulseCal
            self.rfpower = self.pulseCal.rfPower;
            self.intfreq = self.pulseCal.intFreq;
            self.lopower = self.pulseCal.loPower;
            self.startBuffer = self.pulseCal.startBuffer;
            self.measBuffer = self.pulseCal.measBuffer;
            self.endBuffer = self.pulseCal.endBuffer;
            self.cardavg = self.pulseCal.cardAvg;
            self.carddelayoffset = self.pulseCal.cardDelayOffset;
            
            % Measurement pulse
            self.measpulse = self.pulseCal.measurement();
            self.result.rowAxis = self.rffreqVector;
        end
        
        function SetUp(self)
            self.UpdateParams();
            SetUp@measlib.SmartSweep(self);
        end
    end
end