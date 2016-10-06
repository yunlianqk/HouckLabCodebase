classdef Echo < measlib.SmartSweep
    %X180RABI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        delayList = linspace(0, 20e-6, 101);
        pulseCal;
    end
    
    methods
        function self = Echo()
            self = self@measlib.SmartSweep();
            self.name = 'Echo';
            self.IQdata.meastype = 'Echo';
        end
        function SetUp(self)
            if isempty(self.pulseCal)
                self.pulseCal = paramlib.pulseCal();
            end
            self.specfreq = self.pulseCal.qubitFreq;
            self.specpower = self.pulseCal.specPower;
            self.speccw = 0;
            self.rffreq = self.pulseCal.cavityFreq;
            self.rfpower = self.pulseCal.rfPower;
            self.rfcw = 0;
            self.intfreq = self.pulseCal.intFreq;
            self.lopower = self.pulseCal.loPower;
            self.startBuffer = self.pulseCal.startBuffer;
            self.measBuffer = self.pulseCal.measBuffer;
            self.endBuffer = self.pulseCal.endBuffer;
            self.cardavg = self.pulseCal.cardAvg;
            self.carddelayoffset = self.pulseCal.cardDelayOffset;
            X90 = self.pulseCal.X90();
			X180 = self.pulseCal.X180();
			Xm90 = self.pulseCal.Xm90();
            for delay = self.delayList
                currentseq = paramlib.gateSequence(X90);
                currentseq.append(pulselib.delay(delay/2));
                currentseq.append(X180);
				currentseq.append(pulselib.delay(delay/2));
				currentseq.append(Xm90);
                self.gateseq = [self.gateseq, currentseq];
            end
            self.measpulse = self.pulseCal.measurement();
            self.IQdata.rowAxis = self.delayList;
            SetUp@measlib.SmartSweep(self);
        end
        function T2 = FitResult(self)
            T2 = self.IQdata.fit();
        end
    end
end

