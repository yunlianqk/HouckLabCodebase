classdef RBExperiment < explib.SweepM8195
    % Randomized benchmarking experiment
    
    % 'sequenceLengths' is an array that contains the number of Clifford
    % gates in each RB sequence
    % 'sequenceIndices' is an array that specifies the full random Clifford sequence
    
    % Example: sequenceLengths = [1, 3, 6]
    %          sequenceIndices = [21, 14, 13, 18, 24, 22]
    % generates 3 RB sequences:
    %          [C21]
    %          [C21, C14, C13]
    %          [C21, C14, C13, C18, C24, C22]
    
    % An undo gate will be automatically calculated and append to the end
    % of each RB sequence to bring the end result to |g>.
    % Usually sequenceIndices is left as empty and a random sequence will
    % be automatically generated for it.
    % sequenceIndices can also be manually specified. It should satisfy
    % length(sequenceIndices) >= max(sequenceLengths) and each elemement
    % should be an integer between 1 and 24 (for single qubit Clifford group).
    
    properties
        sequenceLengths = unique(round(logspace(log10(1), log10(1000), 25)));
        sequenceIndices = [];
        rbsequences; % object array of randomized benchmarking sequences
    end
    
    properties (SetAccess = private)
        gatedict;
        clfdict;
        clfmat;
        clfstring;
    end
        
    methods
        function self = RBExperiment(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@explib.SweepM8195(pulseCal, config);
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
            if isempty(self.sequenceIndices)
                rng('default');
                rng('shuffle');
                self.sequenceIndices = randi(length(self.clfdict), [1, max(s)]);
            end
            self.rbsequences = pulselib.RB.rbSequence(1, self.clfdict);
            self.sequences = pulselib.gateSequence();
            for row = 1:length(s)
                self.rbsequences(row) ...
                    = pulselib.RB.rbSequence(self.sequenceIndices(1:s(row)), self.clfdict);
                self.sequences(row) = pulselib.gateSequence();
                for col = 1:length(self.rbsequences(row).pulses)
                    self.sequences(row).append(self.rbsequences(row).pulses(col).primDecomp);
                end
            end
            SetUp@explib.SweepM8195(self);
        end
        
        function Plot(self)
            figure(143);
            rbFit = funclib.RBFit(self.sequenceLengths, self.result.AmpInt);
            self.result.Fidelity = rbFit.avgGateFidelity;
        end
    end
end