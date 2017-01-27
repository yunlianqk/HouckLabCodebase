classdef LongTimeDriftDecay < explib.SweepM8195
    % very long rabi drive, vary measure buffer.  gain saturation offset (or
    % whatever it is) should decay to zero as the measure buffer gets
    % large.
    
    properties 
        rabiDuration = 200e-6;
        rabiDrive = 1;
        rabiFreq = 4e9;
        delayList = 200e-9:8e-6:200e-6;
    end
    
    methods
        function self = LongTimeDriftDecay(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.SweepM8195(pulseCal, config);
            self.normalization = 0;
            self.pulseCal.qubitFreq = self.rabiFreq;
        end
        
        function SetUp(self)
            self.pulseCal.qubitFreq = self.rabiFreq;
            rabi = pulselib.measPulse(self.rabiDuration, self.rabiDrive);
            self.sequences = [];
            for delay = self.delayList
                currentseq = paramlib.gateSequence(rabi);
                currentseq.append(pulselib.delay(delay));
                self.sequences = [self.sequences, currentseq];
            end
            SetUp@explib.SweepM8195(self);
        end
        
        function Run(self)
            Run@explib.SweepM8195(self);
            figure(801);
            plot(self.delayList/1e-6, self.result.AmpInt);
            xlabel('Delay (\mus)');
            ylabel('Amplitude');
            title(self.experimentName);
			drawnow;
        end
    end
end
     
        