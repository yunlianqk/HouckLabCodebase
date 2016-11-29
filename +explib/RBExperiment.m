classdef RBExperiment < explib.SweepM8195
    % Randomized benchmarking experiment object
    
    properties
        sequenceLengths = unique(round(logspace(log10(1), log10(3500), 32)));
        rbsequences; % object array of randomized benchmarking sequences
    end
    
    properties (SetAccess = private)
        gatedict;
        clfdict;
        clfmat;
        clfstring;
    end
        
    methods
        function self = RBExperiment(pulseCal)
            self = self@explib.SweepM8195(pulseCal);
            self.histogram = 0;
            self.normalization = 1;
            % Generate Clifford decomposition string
            [self.clfmat, self.clfstring] = pulselib.RB.SingleQubitCliffords();
        end
            
        function SetUp(self)
            % Generate primary gate objects using self.pulseCal
            self.gatedict.Identity = self.pulseCal.Identity();
            self.gatedict.X180 = self.pulseCal.X180();
            self.gatedict.X90 = self.pulseCal.X90();
            self.gatedict.Xm90 = self.pulseCal.Xm90();
            self.gatedict.Y180 = self.pulseCal.Y180();
            self.gatedict.Y90 = self.pulseCal.Y90();
            self.gatedict.Ym90 = self.pulseCal.Ym90();
            % Generate Clifford gate objects
            self.clfdict = [];
            for row = 1:length(self.clfstring)
                primDecomp = [];
                for gateName = self.clfstring{row}
                    primDecomp = [primDecomp, self.gatedict.(gateName{1})];
                end
                self.clfdict = [self.clfdict, ...
                                  pulselib.RB.cliffordGate(row, self.clfmat{row}, primDecomp)];
            end
            % Generate RB sequence objects and gateSequence objects
            s = self.sequenceLengths;
            rng('default');
            rng('shuffle');
            randSequence = randi(length(self.clfdict), [1, max(s)]);
            self.rbsequences = pulselib.RB.rbSequence(1, self.clfdict);
            self.sequences = pulselib.gateSequence();
            for row = 1:length(s)
                seqList = randSequence(1:s(row));
                self.rbsequences(row) = pulselib.RB.rbSequence(seqList, self.clfdict);
                self.sequences(row) = pulselib.gateSequence();
                for col = 1:length(self.rbsequences(row).pulses)
                    self.sequences(row).extend(self.rbsequences(row).pulses(col).primDecomp);
                end
            end
            SetUp@explib.SweepM8195(self);
        end
    end
end
       