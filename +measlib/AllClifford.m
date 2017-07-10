classdef AllClifford < measlib.SmartSweep
    % Repeat all 24 Clifford gates by N=self.repeat times
    % With one additional undo gate at the end
    
    properties
        repeat = 1;
        clfsequences; % object array of randomized benchmarking sequences
    end

    properties (SetAccess = private)
        cliffords;
    end

    properties (Hidden)
        % Pre-calculated waveforms to speed up pulse generation
        gatedict = struct();
        iGateWaveforms = struct();
        qGateWaveforms = struct();
    end

    methods
        function self = AllClifford(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.normalization = 1;
            self.cliffords = pulselib.RB.SingleQubitCliffords();
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
            % Generate RB sequence objects and gateSequence objects
            self.clfsequences = pulselib.RB.rbSequence(1, self.cliffords);
            self.gateseq = pulselib.gateSequence();
            for row = 1:length(self.cliffords)
                self.clfsequences(row) = pulselib.RB.rbSequence(row*ones(1, self.repeat), self.cliffords);
                self.gateseq(row) = pulselib.gateSequence();
                for clifford = self.clfsequences(row).pulses
                    for prim = clifford.primDecomp
                        self.gateseq(row).append(self.gatedict.(prim{1}));
                    end
                end
            end
            SetUp@measlib.SmartSweep(self);
        end

        function Plot(self, fignum)
            if nargin == 1
                fignum = 121;
            end
            self.Integrate();
            if self.normalization
                self.Normalize();
            end
            numseq = length(self.cliffords);
            ticklabels = cell(1, numseq);
            for row = 1:numseq
                gates = self.cliffords(row).primDecomp;
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
            figure(fignum);
            bar(1:length(self.result.normAmp), self.result.normAmp);
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
            title([self.name, ', repeat = ', num2str(self.repeat)]);
            xlabel('Clifford gates');
            ylabel('Amplitude');
			drawnow;
        end
    end
end
       