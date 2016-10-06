classdef Ramsey < measlib.SmartSweep
    %X180RABI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        delayList = linspace(0, 20e-6, 101);
        pulseCal =  paramlib.pulseCal();
    end
    
    methods
        function self = Ramsey()
            self = self@measlib.SmartSweep();
            self.name = 'Ramsey';
            self.IQdata.meastype = 'Ramsey';
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
            X90 = self.pulseCal.X90();
            for delay = self.delayList
                currentseq = paramlib.gateSequence(X90);
                currentseq.append(pulselib.delay(delay));
                currentseq.append(X90);
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

