classdef X180Rabi < measlib.SmartSweep
    %X180RABI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ampVector = linspace(0, 1, 101);
        pulseCal = paramlib.pulseCal();
    end
    
    methods
        function self = X180Rabi(pulseCal)
            self = self@measlib.SmartSweep();
            self.name = 'X180Rabi';
            self.IQdata.meastype = 'Rabi';
            self.speccw = 0;
            self.rfcw = 0;
            if nargin == 1
                self.pulseCal = pulseCal;
            end
            self.UpdateParams();
        end
        function UpdateParams(self)
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
        end
        function SetUp(self)
            self.UpdateParams();
            self.gateseq = [];
            dragRatio = self.pulseCal.X180DragAmplitude/self.pulseCal.X180Amplitude;
            for amp = self.ampVector
                X180 = self.pulseCal.X180();
                X180.amplitude = amp;
                X180.dragAmplitude = dragRatio*amp;
                currentseq = paramlib.gateSequence(X180);
                self.gateseq = [self.gateseq, currentseq];
            end
            self.measpulse = self.pulseCal.measurement();
            self.IQdata.rowAxis = self.ampVector;
            SetUp@measlib.SmartSweep(self);
        end
        function theta = FitResult(self)
            theta = self.IQdata.fit();
        end
    end
end

