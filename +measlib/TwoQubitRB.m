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
        rbsequences;
        repeat = 1;
    end
    
    properties (SetAccess = public)
        % Store all 24 Clifford gates
        cliffords1;
        cliffords2;
    end
    
    properties (Hidden)
        % Pre-calculated waveforms to speed up pulse generation
        gatedict = struct();
        gatedict2 = struct();
        fluxdict = struct();
        iGateWaveforms = struct();
        qGateWaveforms = struct();
        iGateWaveforms2 = struct();
        qGateWaveforms2 = struct();
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
            [self.cliffords1, self.cliffords2] = pulselib.RB.TwoQubitCliffords();
            for gate = {'Identity', 'X180', 'X90','Xm180', 'Xm90', 'Y180', 'Y90','Ym180', 'Ym90'}
                self.gatedict.(gate{1}) = self.pulseCal.(gate{1})();
                self.gatedict2.(gate{1}) = self.pulseCal2.(gate{1})();
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
                fprintf('RB sequence %d of %d running\n', ind, self.repeat);
                % If  sequence indices are not specified, generate indices randomly
                if size(self.sequenceIndices, 1) < ind
                    rng('default');
                    rng('shuffle'); % Seeds randi based on current time
                    self.sequenceIndices(ind, :) = randi(length(self.cliffords2), [1, max(s)]);
                end
                self.gateseq = pulselib.gateSequence();
                self.gateseq2 = pulselib.gateSequence();
                self.fluxseq = pulselib.gateSequence();
                
                % Construct rbsequences and feed in  gateseq,gateseq2 and fluxseq
                for row = 1:length(s)
                    self.rbsequences(row).pulses = self.sequenceIndices(ind, 1:s(row));
                    % Find final unitary matrix
                    unitaryFinal=1;
                    for ii = 1:s(row)
                        index=self.sequenceIndices(ind, ii);
                        unitaryFinal=self.cliffords2(index).unitary*unitaryFinal;
                    end
                    
                    % Find inverse clifford
                    for  ii = 1: length(self.cliffords2)
                        tol=2e-6;
                        if abs(trace(unitaryFinal*self.cliffords2(ii).unitary))>=(length(unitaryFinal)-tol)
                            self.rbsequences(row).inverse=ii;
                            break;
                        end
                    end
                    
                    % Convert 2 qubit clifford indices into prime
                    % decomposition of atomic single qubit cliffords
                    % and update the awg sequences
                    self.gateseq(row) = pulselib.gateSequence();
                    self.gateseq2(row) = pulselib.gateSequence();
                    self.fluxseq(row) = pulselib.gateSequence();
                    if s(row)==0
                        rbseq(self, 1, row); % Just put identity on all the sequences
                    else    
                        for ii = 1:s(row)

                            Clifford2index=self.rbsequences(row).pulses(ii);
                            rbseq(self,Clifford2index,row);
                            if ii==s(row)
                                Clifford2index=self.rbsequences(row).inverse;
                                rbseq(self,Clifford2index,row);
                            end    
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
        
        function rbseq(self, Clifford2index, row)
            % takes in index of clifford2 and updates gateseq,gateseq2 and
            % fluxseq accordingly
            
            % Append pre C-gates
            C1 = self.cliffords2(Clifford2index).primDecomp{1}(1); % Qubit1 clifford
            C2 = self.cliffords2(Clifford2index).primDecomp{1}(2); % Qubit2 clifford
            % Append decomposition of C1/C2 to gateseq/gateseq2
            self.clf1gen(C1, C2, row);
            % Append entangling gate
            if self.cliffords2(Clifford2index).primDecomp{2}
                for e = self.entangling_seq(self.cliffords2(Clifford2index).primDecomp{2});
                    if strcmp('iSWAP', e)
                        % Append iSWAP to fluxseq
                        self.fluxseq(row).append(self.fluxdict.iSWAP);
                        % Append delay to gateseq and gateseq2
                        self.gateseq(row).append(self.pulseCal.Delay(self.fluxdict.iSWAP.totalDuration));
                        self.gateseq2(row).append(self.pulseCal2.Delay(self.fluxdict.iSWAP.totalDuration));
                    else
                        % Append identity to fluxseq
                        self.fluxseq(row).append(self.gatedict.('Identity'));
                        % Append single qubit gates to gateseq and gateseq2
                        self.gateseq(row).append(self.gatedict.(e{1}{1}));
                        self.gateseq2(row).append(self.gatedict2.(e{1}{2}));
                    end
                end
            end
            % Append post S-gates
            if self.cliffords2(Clifford2index).primDecomp{3}
                S1 = self.cliffords2(Clifford2index).primDecomp{3}(1);
                S2 = self.cliffords2(Clifford2index).primDecomp{3}(2);
                % Append decomposition of S1/S2 to gateseq/gateseq2
                self.clf1gen(S1, S2, row);
            end
        end
        
        function clf1gen(self, C1, C2, row)
            % Takes in single qubit clifford gates and updates the generator
            % pulse sequence appropriately
            C1decom = self.singleClifford(C1);
            C2decom = self.singleClifford(C2);
            for counter = 1:max(length(C2decom), length(C1decom))
                self.fluxseq(row).append(self.gatedict.('Identity'));
                if counter > length(C1decom)
                    % Add extra identity gates on qubit1
                    self.gateseq(row).append(self.gatedict.('Identity'));
                else
                    self.gateseq(row).append(self.gatedict.(C1decom{counter}));
                end
                if counter > length(C2decom)
                    % Add extra identity gates on qubit2
                    self.gateseq2(row).append(self.gatedict2.('Identity'));
                else
                    self.gateseq2(row).append(self.gatedict2.(C2decom{counter}));
                end
            end
        end
        
        function AtomDecom = singleClifford(self, ind)
            % Function to generate randomly chosen atomic clifford decomp
            % for the given gate
            % ind is an index of cliffords1
            
            % Randomly choose which atomic cliffords are used to generate
            % this single qubit clifford
            DecInd = randsample(self.cliffords1(ind).primDecomp, 1);
            % Randomly choose between +180 and -180 X/Y rotation and map
            % the atomic clifford indices to their names
            for ii = 1:length(DecInd{1})
                %                 disp(DecInd{ii});
                switch DecInd{1}(ii)
                    case 1
                        AtomDecom{ii} = 'Identity';
                    case 2
                        AtomDecom{ii} = 'X90';
                    case 4
                        AtomDecom{ii} = 'Xm90';
                    case 5
                        AtomDecom{ii} = 'Y90';
                    case 7
                        AtomDecom{ii} = 'Ym90';
                    case 3
                        % randsample returns a cell, so using '()' instead
                        % of '{}' here
                        AtomDecom(ii) = randsample({'X180', 'Xm180'}, 1);
                    case 6
                        AtomDecom(ii) = randsample({'Y180', 'Ym180'}, 1);
                    otherwise
                        disp('Pulse number should be between 1-7');
                end
            end
        end
        
        function EntgateSeq = entangling_seq(~, gate)
            % Helper function to create entangling gate seq in terms of iSWAP
            % Decomposition taken from N. Schuch and J. Siewert, Phys. Rev. A 67, 032301 (2003).
            % Ignoring all single qubit gates in the start and end of the
            % entangling gate
            switch gate
                case 'CNOT'
                % put X90 gate on the control qubit
                    EntgateSeq = {'iSWAP', {'X90','Identity'}, 'iSWAP'};
                case 'iSWAP'
                    EntgateSeq = {'iSWAP'};
                case 'SWAP'
                    EntgateSeq = {'iSWAP', {'Xm90', 'Identity'}, ...
                                  'iSWAP', {'Identity', 'Xm90'}, 'iSWAP'};
                otherwise
                    disp('Only CNOT, iSWAP or SWAP allowed');
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
end