classdef SweepQubitFrequency < explib.SweepM8195
    
    properties
        qubitGates = {};
        freqVector;
    end
    
    methods
        function self = SweepQubitFrequency(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.SweepM8195(pulseCal, config);
            self.normalization = 0;
            self.histogram = 0;
            self.qubitFreq = self.freqVector;
        end
        
        function SetUp(self)
            self.qubitFreq = self.freqVector;
            if ~isempty(self.qubitGates) && ~iscell(self.qubitGates)
                self.qubitGates = cellstr(self.qubitGates);
            end
            self.sequences = pulselib.gateSequence();
            for col = 1:length(self.qubitGates)
                gate = pulselib.singleGate(self.qubitGates{col}, self.pulseCal);
                self.sequences.append(gate);
            end
            SetUp@explib.SweepM8195(self);
        end
        
        function Run(self)
            Run@explib.SweepM8195(self);
            self.Plot();
        end
        
        function Plot(self)
            figure(110);
            plot(self.freqVector/1e9, self.result.AmpInt);
            xlabel('Frequency (GHz)');
            ylabel('Amplitude');
            title(self.experimentName);
			drawnow;
        end
    end
end