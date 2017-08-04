 classdef TwoQubitRB < measlib.SmartSweep
    % Randomized benchmarking experiment for two qubits
    
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
        % Store all 24 single-qubit Clifford gates
        cliffords1;
        % Store all 11520 two-qubit Clifford gates
        cliffords2;
    end
    
    properties (Hidden)
        % Pre-calculated waveforms to speed up pulse generation
        gatedict = struct();
        gatedict2 = struct();
        fluxdict = struct();
    end
    
    methods
        function self = TwoQubitRB(pulseCal, pulseCal2, config)
            if nargin == 2
                config = [];
            end
            self = self@measlib.SmartSweep(config);
            self.pulseCal = pulseCal;
            self.pulseCal2 = pulseCal2;
            self.normalization = 1;
            self.cliffords1 = pulselib.RB.SingleQubitCliffords();
            self.cliffords2 = pulselib.RB.TwoQubitCliffords();
            for gate = {'Identity', 'X180', 'X90','Xm180', 'Xm90', ...
                        'Y180', 'Y90','Ym180', 'Ym90'}
                self.gatedict.(gate{1}) = self.pulseCal.(gate{1});
                self.gatedict2.(gate{1}) = self.pulseCal2.(gate{1});
            end
            self.fluxdict.iSWAP = self.pulseCal.iSWAP;
            self.fluxdict.Identity = self.gatedict.Identity;
        end
        
        function Run(self)
            s = self.sequenceLengths;
            result = struct();
            result.normAmp = zeros(self.repeat, length(self.sequenceLengths));
            result.intI = zeros(self.repeat, length(self.sequenceLengths)+2);
            result.intQ = zeros(self.repeat, length(self.sequenceLengths)+2);
            self.savefile = [self.name, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];

            for ind = 1:self.repeat
                % If  sequence indices are not specified, generate indices randomly
                if size(self.sequenceIndices, 1) < ind
                    rng('default');
                    rng('shuffle'); % Seeds randi based on current time
                    self.sequenceIndices(ind, :) = randi(length(self.cliffords2), [1, max(s)]);
                end
                self.gateseq = pulselib.gateSequence();
                self.gateseq2 = pulselib.gateSequence();
                self.fluxseq = pulselib.gateSequence();

                % Set the first gate to be identity
                % This fixes the error when sequenceLengths(1) = 0
                self.rbsequences(1).indices(1) = 1;
                % Construct rbsequences and feed into gateseq, gateseq2 and fluxseq
                for row = 1:length(s)
                    % Pass indices to rbsequence
                    self.rbsequences(row).indices = self.sequenceIndices(ind, 1:s(row));
                    % Find the inverse Clifford gate for rbsequence
                    self.FindInverse(row);
                    % Convert Clifford indices into prime decomposition
                    % and update the awg sequences
                    self.gateseq(row) = pulselib.gateSequence();
                    self.gateseq2(row) = pulselib.gateSequence();
                    self.fluxseq(row) = pulselib.gateSequence();
                    for C2index = self.rbsequences(row).indices
                        self.C2gate2Seq(C2index ,row);
                    end
                    % Append inverse gate to end of sequence
                    self.C2gate2Seq(self.rbsequences(row).inverse, row);
                end
                % Run experiment
                self.SetUp();
                fprintf('RB sequence %d of %d running\n', ind, self.repeat);
                Run@measlib.SmartSweep(self);
                % Update results
                result.normAmp(ind, :) = self.result.normAmp;
                result.intI(ind, :) = self.result.intI;
                result.intQ(ind, :) = self.result.intQ;
                % Plot and fit results
                figure(146);
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
                fignum = 146;
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
            unitary = eye(4);
            for ii = self.rbsequences(row).indices
                unitary = self.cliffords2(ii).unitary*unitary;
            end

            % Find inverse clifford
            tol = 2e-6;
            for ii = 1:length(self.cliffords2)
                if abs(trace(unitary*self.cliffords2(ii).unitary)) >= (4-tol)
                    self.rbsequences(row).inverse = ii;
                    break;
                end
            end
        end

        function C2gate2Seq(self, C2index, row)
            % Takes in two-qubit gate indexed by C2index
            % updates gateseq, gateseq2 and fluxseq

            % Pre C-gates
            C1 = self.cliffords2(C2index).primDecomp{1}(1);
            C2 = self.cliffords2(C2index).primDecomp{1}(2);
            self.C1gate2Seq(C1, C2, row);
            % Mid E-gate
            if ~isempty(self.cliffords2(C2index).primDecomp{2})
                E =  self.cliffords2(C2index).primDecomp{2};
                self.Egate2Seq(E, row);
            end
            % Post S-gates
            if ~isempty(self.cliffords2(C2index).primDecomp{3})
                S1 = self.cliffords2(C2index).primDecomp{3}(1);
                S2 = self.cliffords2(C2index).primDecomp{3}(2);
                self.C1gate2Seq(S1, S2, row);
            end
        end

        function C1gate2Seq(self, C1, C2, row)
            % Takes in single qubit clifford gates indexed by C1 and C2,
            % updates gatesewq, gateseq2 and fluxseq
            C1PrimString = self.GetPrimString(C1);
            C2PrimString = self.GetPrimString(C2);
            for ii = 1:max(length(C2PrimString), length(C1PrimString))
                self.fluxseq(row).append(self.gatedict.Identity);
                if ii > length(C1PrimString)
                    % Add extra identity gates on qubit1
                    self.gateseq(row).append(self.gatedict.Identity);
                else
                    self.gateseq(row).append(self.gatedict.(C1PrimString{ii}));
                end
                if ii > length(C2PrimString)
                    % Add extra identity gates on qubit2
                    self.gateseq2(row).append(self.gatedict2.Identity);
                else
                    self.gateseq2(row).append(self.gatedict2.(C2PrimString{ii}));
                end
            end
        end

        function Egate2Seq(self, Egate, row)
            % Takes in entangle gate Egate,
            % updates gateseq, gateseq2, fluxseq
            switch Egate
                case 'CNOT'
                    gateSeq = {'iSWAP', {'X90', 'Identity'}, 'iSWAP'};
                case 'iSWAP'
                    gateSeq = {'iSWAP'};
                case 'SWAP'
                    gateSeq = {'iSWAP', {'Xm90', 'Identity'}, ...
                               'iSWAP', {'Identity', 'Xm90'}, 'iSWAP'};
                otherwise
                    disp('Only CNOT, iSWAP or SWAP allowed');
            end
            for gate = gateSeq
                if strcmp(gate{1}, 'iSWAP')
                    % Append iSWAP to fluxseq
                    self.fluxseq(row).append(self.fluxdict.iSWAP);
                    % Append delay to gateseq and gateseq2
                    self.gateseq(row).append(self.pulseCal.Delay(self.fluxdict.iSWAP.totalDuration));
                    self.gateseq2(row).append(self.pulseCal2.Delay(self.fluxdict.iSWAP.totalDuration));
                else
                    % Append identity to fluxseq
                    self.fluxseq(row).append(self.gatedict.Identity);
                    % Append single qubit gates to gateseq and gateseq2
                    self.gateseq(row).append(self.gatedict.(gate{1}{1}));
                    self.gateseq2(row).append(self.gatedict2.(gate{1}{2}));
                end
            end
        end

        function primString = GetPrimString(self, C1index)
            % Return the namestrings for primary decomposition of
            % single-qubit Clifford gate
            
            % Randomly choose a primary gate decomposition
            primDecomp = randsample(self.cliffords1(C1index).primDecomp, 1);
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