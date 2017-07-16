classdef SingleQubitRB < measlib.SmartSweep
% Randomized benchmarking experiment for single qubit

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
        rbsequences = struct('indices', [], 'inverse', []);
        repeat = 1;
    end
    
    properties (SetAccess = private)
        % Store all 24 Clifford gates
        cliffords;
    end
    
    properties (Hidden)
        % Pre-calculated waveforms to speed up pulse generation
        gatedict = struct();
        % Index for current repeat
        irepeat;
    end
        
    methods
        function self = SingleQubitRB(pulseCal, config)
            if nargin == 1
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.normalization = 1;
            self.cliffords = pulselib.RB.SingleQubitCliffords();
            for gate = {'Identity', 'X180', 'X90','Xm180', 'Xm90', ...
                        'Y180', 'Y90','Ym180', 'Ym90'}
                self.gatedict.(gate{1}) = self.pulseCal.(gate{1});
            end
        end
        
        function SetUp(self)
            s = self.sequenceLengths;
            ind = self.irepeat;
            % If sequence indices are not specified, generate indices randomly
            if size(self.sequenceIndices, 1) < ind
                rng('default');
                rng('shuffle');
                self.sequenceIndices(ind, :) = randi(length(self.cliffords), [1, max(s)]);
            end
            self.gateseq = pulselib.gateSequence();

            % Set the first gate to be identity
            % This fixes the error when sequenceLengths(1) = 0
            self.rbsequences(1).indices(1) = 1;
            % Construct rbsequences and feed into gateseq
            for row = 1:length(s)
                % Pass indices to rbsequence
                self.rbsequences(row).indices = self.sequenceIndices(ind, 1:s(row));
                % Find the inverse Clifford gate for rbsequence
                self.FindInverse(row);
                % Convert Clifford indices into prime decomposition
                % and update the awg sequences
                self.gateseq(row) = pulselib.gateSequence();
                for C1index = self.rbsequences(row).indices
                    self.C1gate2Seq(C1index ,row);
                end
                % Append inverse gate to end of sequence
                self.C1gate2Seq(self.rbsequences(row).inverse, row);
            end
            SetUp@measlib.SmartSweep(self);
        end

        function Run(self)
            % Construct result struct
            result = struct();
            result.normAmp = zeros(self.repeat, length(self.sequenceLengths));
            result.intI = zeros(self.repeat, length(self.sequenceLengths)+2);
            result.intQ = zeros(self.repeat, length(self.sequenceLengths)+2);
            % Set save file name
            self.savefile = [self.name, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];

            for ind = 1:self.repeat
                self.irepeat = ind;
                % Run experiment
                self.SetUp();
                fprintf('RB sequence %d of %d running\n', ind, self.repeat);
                Run@measlib.SmartSweep(self);
                % Update results
                result.normAmp(ind, :) = self.result.normAmp;
                result.intI(ind, :) = self.result.intI;
                result.intQ(ind, :) = self.result.intQ;
                % Plot and fit results
                figure(144);
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
            subplot(1, 2, 2);
            xlabel('# of Cliffords');
            ylabel('P(|0>)');
            colorbar;
            self.result.normAmp = result.normAmp;
            self.result.intI = result.intI;
            self.result.intQ = result.intQ;
            if self.autosave
                self.Save();
            end
        end

        function Plot(self, fignum)
            if nargin == 1
                fignum = 144;
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

    methods (Access = protected)
        function FindInverse(self, row)
            % Find the inverse Clifford for rbsequence(row)

            % Calculate unitary
            unitary = eye(2);
            for ii = self.rbsequences(row).indices
                unitary = self.cliffords(ii).unitary*unitary;
            end

            % Find inverse
            tol = 2e-6;
            for ii = 1:length(self.cliffords)
                if abs(trace(unitary*self.cliffords(ii).unitary)) >= (2-tol)
                    self.rbsequences(row).inverse = ii;
                    break;
                end
            end
        end

        function C1gate2Seq(self, C1index, row)
            % Takes in single qubit clifford gate index,
            % updates gateseq
            C1PrimString = self.GetPrimString(C1index);
            for ii = 1:length(C1PrimString)
                self.gateseq(row).append(self.gatedict.(C1PrimString{ii}));
            end
        end

        function primString = GetPrimString(self, C1index)
            % Return the namestrings for primary decomposition of
            % single-qubit Clifford gate

            % Randomly choose a primary gate decomposition
            primDecomp = randsample(self.cliffords(C1index).primDecomp, 1);
            % Randomly choose between +180 and -180 X/Y rotation and map
            % the atomic clifford indices to their names
            for ii = 1:length(primDecomp{1})
                switch primDecomp{1}(ii)
                    case 1
                        primString{ii} = 'Identity';
                    case 2
                        primString{ii} = 'X90';
                    case 4
                        primString{ii} = 'Xm90';
                    case 5
                        primString{ii} = 'Y90';
                    case 7
                        primString{ii} = 'Ym90';
                    case 3
                        % randsample returns a cell,
                        % so using '()' instead of '{}' here
                        primString(ii) = randsample({'X180', 'Xm180'}, 1);
                    case 6
                        primString(ii) = randsample({'Y180', 'Ym180'}, 1);
                    otherwise
                        disp('Pulse number should be between 1-7');
                end
            end
        end
    end
end