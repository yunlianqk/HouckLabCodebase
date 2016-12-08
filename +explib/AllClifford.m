classdef AllClifford < explib.SweepM8195
    % Repeat all 24 Clifford gates by N=self.repeat times
    % With one additional undo gate at the end
    
    properties
        repeat = 1;
        clfsequences; % object array of randomized benchmarking sequences
    end
    
    properties (SetAccess = private)
        gatedict;
        clfdict;
        clfmat;
        clfstring;
    end
        
    methods
        function self = AllClifford(pulseCal, config)
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
            self.clfsequences = pulselib.RB.rbSequence(1, self.clfdict);
            self.sequences = pulselib.gateSequence();
            for row = 1:length(self.clfdict)
                self.clfsequences(row) = pulselib.RB.rbSequence(row*ones(1, self.repeat), self.clfdict);
                self.sequences(row) = pulselib.gateSequence();
                for col = 1:length(self.clfsequences(row).pulses)
                    self.sequences(row).append(self.clfsequences(row).pulses(col).primDecomp);
                end
            end
            SetUp@explib.SweepM8195(self);
        end
        
        function Run(self)
            Run@explib.SweepM8195(self);
            self.Plot();
        end
        
        function Plot(self)
            numseq = length(self.clfstring);
            ticklabels = cell(1, numseq);
            for row = 1:numseq
                gates = self.clfstring{row};
                for col = 1:length(gates)
                    switch gates{col}
                        case 'Identity'
                            ticklabels{row} = [ticklabels{row}, 'Id'];
                        case 'X180'
                            ticklabels{row} = [ticklabels{row}, 'X_p'];
                        case 'X90'
                            ticklabels{row} = [ticklabels{row}, 'X_9'];
                        case 'Xm90'
                            ticklabels{row} = [ticklabels{row}, 'X_9^-'];
                        case 'Y180'
                            ticklabels{row} = [ticklabels{row}, 'Y_p'];
                        case 'Y90'
                            ticklabels{row} = [ticklabels{row}, 'Y_9'];
                        case 'Ym90'
                            ticklabels{row} = [ticklabels{row}, 'Y_9^-'];
                        otherwise
                            display(['Unknown gate: ', gates{col}]);
                    end
                end
            end
            figure(753);
            bar(1:length(self.clfdict), self.result.AmpInt);
            set(gca, 'xtick', 1:numseq);
            set(gca, 'xticklabel', ticklabels);
            set(gca, 'xticklabelrotation', 45);
            ylim([-0.2, 1.2]);
            plotlib.hline(0);
            plotlib.hline(1);
            hold on;
            for ind = 1:numseq
                plot([ind, ind], [-0.2, 0], 'r:');
            end
            hold off;
            title([self.experimentName, ', repeat = ', num2str(self.repeat)]);
            xlabel('Clifford gates');
            ylabel('Amplitude');
        end
    end
end
       