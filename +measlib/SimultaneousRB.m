classdef SimultaneousRB < measlib.SmartSweep
    % Simultaneous RB for two qubits
    
    % 'sequenceLengths' is an array that contains the number of Clifford
    % gates in each RB sequence
    % 'sequenceIndices' is an array that specifies the full random Clifford sequence
    % 'repeat' is the number of different RB sequences to run
    
    % Example: sequenceLengths = [1, 3, 6]
    %          sequenceIndices = [21, 14, 13, 18, 24, 22]
    % generates 3 RB sequences:
    %          [C21]
    %          [C21, C14, C13]
    %          [C21, C14, C13, C18, C24, C22]
    
    % An undo gate will be automatically calculated and append to the end
    % of each RB sequence to bring the end result to |g>.
    % Usually sequenceIndices is left as empty and random sequencea will
    % be automatically generated for it.
    % sequenceIndices can also be manually specified. It should satisfy
    % size(sequenceIndices, 1) = self.repeat,
    % size(sequenceIndices, 2) >= max(sequenceLengths),
    % and each elemement should be an integer between 1 and 24.
    
    properties
        sequenceLengths = unique(round(logspace(log10(1), log10(1000), 25)));
        sequenceIndices = [];
        rbsequences;
        repeat = 1;
    end
    
    properties (SetAccess = private)
        % Store all 24 Clifford gates
        cliffords;
    end
    
    properties (Hidden)
        % Pre-calculated waveforms to speed up pulse generation
        gatedict = struct();
        gatedict2 = struct();
    end
        
    methods
        function self = SimultaneousRB(pulseCal, pulseCal2, config)
            if nargin == 2
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.pulseCal2 = pulseCal2;
            self.normalization = 1;
            self.cliffords = pulselib.RB.SingleQubitCliffords();

            for gate = {'Identity', 'X180', 'X90', 'Xm90', 'Y180', 'Y90', 'Ym90'}
                self.gatedict.(gate{1}) = self.pulseCal.(gate{1})();
            end
            for gate = {'Identity', 'X180', 'X90', 'Xm90', 'Y180', 'Y90', 'Ym90'}
                self.gatedict2.(gate{1}) = self.pulseCal2.(gate{1})();
            end
        end
        
        function Run(self)
            s = self.sequenceLengths;
            result = struct();
            result.normAmp = zeros(self.repeat, length(self.sequenceLengths));
            result.intI = zeros(self.repeat, length(self.sequenceLengths)+2);
            result.intQ = zeros(self.repeat, length(self.sequenceLengths)+2);
            self.savefile = [self.name, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];

            for ind = 1:self.repeat
                fprintf('RB sequence %d of %d running\n', ind, self.repeat);
                % If  sequence indices are not specified, generate indices randomly
                if size(self.sequenceIndices, 1) < ind
                    rng('default');
                    rng('shuffle');
                    self.sequenceIndices(ind, :) = randi(length(self.cliffords), [1, max(s)]);
                end
                self.gateseq = pulselib.gateSequence();
                self.gateseq2 = pulselib.gateSequence();
                self.rbsequences = pulselib.RB.rbSequence(1, self.cliffords);
                % Construct rbsequences and gateseq
                for row = 1:length(s)
                    self.rbsequences(row) ...
                        = pulselib.RB.rbSequence(self.sequenceIndices(ind, 1:s(row)), self.cliffords);
                    self.gateseq(row) = pulselib.gateSequence();
                    self.gateseq2(row) = pulselib.gateSequence();
                    for clifford = self.rbsequences(row).pulses
                        for prim = clifford.primDecomp
                            self.gateseq(row).append(self.gatedict.(prim{1}));
                            self.gateseq2(row).append(self.gatedict2.(prim{1}));
                        end
                    end
                end
                % Run experiment
                SetUp(self);
                Run@measlib.SmartSweep(self);
                % Update results
                result.normAmp(ind, :) = self.result.normAmp;
                result.intI(ind, :) = self.result.intI;
                result.intQ(ind, :) = self.result.intQ;
                % Plot and fit results
                figure(145);
                subplot(1, 2, 1);
                imagesc(result.normAmp(1:ind, :));
                title([self.name, ' ', num2str(ind), ' of ', num2str(self.repeat)]);
                subplot(1, 2, 2);
                self.result.rbFit = funclib.RBFit(self.sequenceLengths, result.normAmp(1:ind, :));
                drawnow;
            end
            subplot(1, 2, 1);
            imagesc(self.sequenceLengths, 1:ind, self.result.normAmp);
            xlabel('# of Cliffords');
            ylabel('Sequence');
            title(self.name);
            colorbar;
            subplot(1, 2, 2);
            xlabel('# of Cliffords');
            ylabel('P(|0>)');
            self.result.normAmp = result.normAmp;
            self.result.intI = result.intI;
            self.result.intQ = result.intQ;
            if self.autosave
                self.Save();
            end
        end

        function Plot(self, fignum)
            if nargin == 1
                fignum = 145;
            end
            figure(fignum);
            subplot(1, 2, 1);
            imagesc(self.sequenceLengths, 1:self.repeat, self.result.normAmp);
            xlabel('# of Cliffords');
            ylabel('Sequence');
            colorbar;
            title(self.name);
            subplot(1, 2, 2);
            funclib.RBFit(self.sequenceLengths, self.result.normAmp);
            xlabel('# of Cliffords');
            ylabel('P(|0>)');
			drawnow;
        end
    end
end