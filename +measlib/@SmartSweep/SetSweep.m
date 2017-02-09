function SetSweep(self)

    global rfgen specgen logen specgen2 fluxgen ...
           yoko1 yoko2 pulsegen1 pulsegen2;

    emsg1 = 'Arrays must have the same number of rows';
    emsg2 = 'Arrays must have the same number of columns';

    % Reset all parameters
    self.numSweep1 = 1;
    self.numSweep2 = 1;
    self.sweep1data = {};
    self.sweep1func = {};
    self.sweep2data = {};
    self.sweep2func = {};
    self.sweep3data = {};
    self.sweep3func = {};
    ii = 1;
    jj = 1;
    kk = 1;

    % Set up sweep data and function handles for generators, yokos, AWG, etc.
    self.lofreq = self.rffreq + self.intfreq;  % lofreq needs to be swept together with rffreq
    
    % Each entry in pName is the name string of one property of the class 
    % that can be swept.
    % Each entry in fHdle is the function handle that sets the
    % corresponding instrument parameter
    pName = {'rffreq', 'rfpower', 'rfphase', ...
             'specfreq', 'specpower', 'specphase', ...
             'lofreq', 'lopower', 'lophase', ...
             'fluxfreq', 'fluxpower', 'fluxphase', ...
             'spec2freq', 'spec2power', 'spec2phase', ...
             'yoko1volt', 'yoko2volt', ...
             'gateseq', 'fluxseq'};
    fHdle = {@rfgen.SetFreq, @rfgen.SetPower, @rfgen.SetPhase, ...
             @specgen.SetFreq, @specgen.SetPower, @specgan.SetPhase, ...
             @logen.SetFreq, @logen.SetPower, @logen.SetPhase, ...
             @fluxgen.SetFreq, @fluxgen.SetPower, @fluxgen.SetPhase, ...
             @specgen2.SetFreq, @specgen2.SetPower, @specgen2.SetPhase, ...
             @yoko1.SetVoltage, @yoko2.SetVoltage, ...
             @setgatewav, @setfluxwav};
    % Set up the sweep according to the shape of the pName{idx}
    for idx = 1:length(pName)
        shape = size(self.(pName{idx}));
        if prod(shape) > 1
        % If not scalar
            if shape(1) > 1
                if shape(2) == 1
                % If column vector, set to outer loop
                    self.sweep1data{ii} = self.(pName{idx});
                    self.sweep1func{ii} = fHdle{idx};
                    ii = ii + 1;
                    if (self.numSweep1 > 1) && (self.numSweep1 ~= shape(1))
                        error(emsg1);
                    end
                    self.numSweep1 = shape(1);
                else
                % If 2D array, set to both loops
                    self.sweep3data{kk} = self.(pName{idx});
                    self.sweep3func{kk} = fHdle{idx};
                    kk = kk + 1;
                    if (self.numSweep1 > 1) && (self.numSweep1 ~= shape(1))
                        error(emsg1);
                    end
                    if (self.numSweep2 > 1) && (self.numSweep2 ~= shape(2))
                        error(emsg2);
                    end
                    self.numSweep1 = shape(1);
                    self.numSweep2 = shape(2);
                end
            else
            % If row vector, set to inner loop
                self.sweep2data{jj} = self.(pName{idx});
                self.sweep2func{jj} = fHdle{idx};
                jj = jj + 1;
                if (self.numSweep2 > 1) && (self.numSweep2 ~= shape(2))
                    error(emsg2);
                end
                self.numSweep2 = shape(2);
            end
        end
    end
    
    % Handle the case for raw AWG waveform
    pName = {'awgch1', 'awgch2', 'awgch3', 'awgch4'};
    fHdle = {@setawgch1, @setawgch2, @setawgch3, @setawgch4};
    for idx = 1:length(pName)
        shape = size(self.(pName{idx}));
        if shape(1) > 1
        % If 2D array, set to INNER loop
        % Each row corresonds to one waveform
            self.sweep2data{jj} = (self.(pName{idx}))';
            self.sweep2func{jj} = fHdle{idx};
            jj = jj + 1;
            if (self.numSweep2 > 1) && (self.numSweep2 ~= shape(1))
                error(emsg2);
            end
            self.numSweep2 = shape(1);
        end
    end
    % Add function handles for starting AWGs
    if numel(self.gateseq) > 1 || size(self.awgch1, 1) > 1 ...
       || size(self.awgch2, 1) > 1
        self.sweep2data{jj} = zeros(1, self.numSweep2);
        self.sweep2func{jj} = @startawg1;
        jj = jj + 1;
    end
    if numel(self.fluxseq) > 1 || size(self.awgch3, 1) > 1 ...
       || size(self.awgch4, 1) > 1
        self.sweep2data{jj} = zeros(1, self.numSweep2);
        self.sweep2func{jj} = @startawg2;
        jj = jj + 1;
    end
    
    % For repeating gates, pre-calculate baseband waveform for all primitive gates
    % in order to speed up gate calibration
     if isprop(self, 'gatedict')
        self.iGateWaveforms = struct();
        self.qGateWaveforms = struct();
        for gateName = fieldnames(self.gatedict)'
            tGate = 0:1/self.pulseCal.samplingRate:self.gatedict.(gateName{1}).totalDuration;
            [self.iGateWaveforms.(gateName{1}), self.qGateWaveforms.(gateName{1})] ...
                = self.gatedict.(gateName{1}).uwWaveforms(tGate, 0);
        end
    end
%=================functions whose handles are used above===================
    % Set AWG waveforms
    function setgatewav(gateseq)
        if isprop(self, 'gatedict')
            % Use pre-calculated baseband waveforms if possible
            pulsegen1.waveform1 = zeros(1, length(self.awgtaxis));
            pulsegen1.waveform2 = zeros(1, length(self.awgtaxis));
            start = find(self.awgtaxis >= (self.seqEndTime - gateseq.totalSequenceDuration), 1);
            for col = 1:len(gateseq)
                % For each gate in the current sequence s
                gate = gateseq.gateArray{col}.name;
                % Find pre-calculated baseband waveform by its name
                itemp = self.iGateWaveforms.(gate);
                qtemp = self.qGateWaveforms.(gate);
                % Update the corresponding segment in the waveform
                stop = start + length(itemp) - 1;
                pulsegen1.waveform1(start:stop) = itemp;
                pulsegen1.waveform2(start:stop) = qtemp;
                % Go to next gate
                start = stop;
            end
        else
            % Otherwise calculate waveforms from gateSequence object
             [pulsegen1.waveform1, pulsegen1.waveform2] ...
                = gateseq.uwWaveforms(self.awgtaxis, self.seqEndTime-gateseq.totalSequenceDuration);
        end
    end
    function setfluxwav(fluxseq)
        [pulsegen2.waveform2, ~] ...
            = fluxseq.uwWaveforms(self.awgtaxis, ...
                                  self.seqEndTime-fluxseq.totalSequenceDuration);
    end
    % For raw AWG waveform input
    function setawgch1(waveform)
        pulsegen1.waveform1 = waveform';
    end
    function setawgch2(waveform)
        pulsegen1.waveform2 = waveform';
    end
    function setawgch3(waveform)
        pulsegen2.waveform1 = waveform';
    end
    function setawgch4(waveform)
        pulsegen2.waveform2 = waveform';
    end
    % Start generation for AWG
    function startawg1(~)
        pulsegen1.Generate();
    end
    function startawg2(~)
        pulsegen2.Generate();
    end
end