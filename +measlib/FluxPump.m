classdef FluxPump < measlib.SmartSweep
    %X180RABI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        durationList = linspace(0, 5e-6, 101);
        pumpAmp = 1.0;
        pulseCal = paramlib.pulseCal();
        fluxBuffer = 200e-9;
        sigma = 10e-9;
    end
    
    methods
        function self = FluxPump(pulseCal)
            self = self@measlib.SmartSweep();
            self.name = 'FluxPump';
            self.IQdata.meastype = 'FluxPump';
            self.speccw = 0;
            self.rfcw = 0;
            self.fluxcw = 0;
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
            
            self.gateseq = [];
            self.fluxseq = [];
            X180 = self.pulseCal.X180();
            for duration = self.durationList
                % Define rectangular pulse as flux drive
                fluxseq = paramlib.gateSequence();
                fluxpulse = pulselib.measPulse(duration, self.pumpAmp, ...
                                               0, self.sigma);
                fluxseq.append(fluxpulse);
                self.fluxseq = [self.fluxseq, fluxseq];
                % Define pi pulse + delay as qubit drive
                gateseq = paramlib.gateSequence();
                gateseq.append(X180);
                gateseq.append(pulselib.delay(fluxpulse.totalDuration ...
                                              + self.fluxBuffer));
                self.gateseq = [self.gateseq, gateseq];

            end
            self.measpulse = self.pulseCal.measurement();
            self.IQdata.rowAxis = self.durationList;
        end        
        function SetUp(self)
            self.UpdateParams();
            SetUp@measlib.SmartSweep(self);
        end
    end
end

