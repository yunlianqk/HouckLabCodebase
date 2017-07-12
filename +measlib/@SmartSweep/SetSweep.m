function SetSweep(self)

    global rfgen specgen logen rfgen2 specgen2 logen2 fluxgen ...
           pulsegen1 pulsegen2 yoko1 yoko2;

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
    self.lo2freq = self.rf2freq + self.int2freq;
    % Each entry in pName is the name string of one property of the class
    % that can be swept.
    % Each entry in fHdle is the function handle that sets the
    % corresponding instrument parameter
    pName = {'rffreq', 'rfpower', 'rfphase', ...
             'specfreq', 'specpower', 'specphase', ...
             'lofreq', 'lopower', 'lophase', ...
             'fluxfreq', 'fluxpower', 'fluxphase', ...
             'rf2freq', 'rf2power', 'rf2phase', ...
             'spec2freq', 'spec2power', 'spec2phase', ...
             'lo2freq', 'lo2power', 'lo2phase', ...
             'yoko1volt', 'yoko2volt', ...
             'gateseq', 'gateseq2', 'fluxseq'};
    fHdle = {@rfgen.SetFreq, @rfgen.SetPower, @rfgen.SetPhase, ...
             @specgen.SetFreq, @specgen.SetPower, @specgan.SetPhase, ...
             @logen.SetFreq, @logen.SetPower, @logen.SetPhase, ...
             @fluxgen.SetFreq, @fluxgen.SetPower, @fluxgen.SetPhase, ...
             @rfgen2.SetFreq, @rfgen2.SetPower, @rfgen2.SetPhase, ...
             @specgen2.SetFreq, @specgen2.SetPower, @specgen2.SetPhase, ...
             @logen2.SetFreq, @logen2.SetPower, @logen2.SetPhase, ...
             @yoko1.SetVoltage, @yoko2.SetVoltage, ...
             @setgatewav, @setgatewav2, @setfluxwav};
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

    % Add function handles for regenerating AWG waveforms
    sweepawg = zeros(1, 2);
    seq = {self.gateseq, self.gateseq2, self.fluxseq};
    for index = 1:length(seq)
        if numel(seq{index}) > 1
            if (~isempty(self.awg{index})) && (self.awg{index} == pulsegen1) ...
               && ~sweepawg(1)
                sweepawg(1) = 1;
                self.sweep2data{jj} = zeros(1, self.numSweep2);
                self.sweep2func{jj} = @startawg1;
                jj = jj + 1;
            end
            if (~isempty(self.awg{index})) && (self.awg{index} == pulsegen2) ...
               && ~sweepawg(2)
                sweepawg(2) = 1;
                self.sweep2data{jj} = zeros(1, self.numSweep2);
                self.sweep2func{jj} = @startawg2;
                jj = jj + 1;
            end
        end
    end
    
    % For repeating gates, pre-calculate baseband waveform for all primitive gates
    % in order to speed up gate calibration
    if isprop(self, 'gatedict')
        iGateWaveforms = struct();
        qGateWaveforms = struct();
        for gateName = fieldnames(self.gatedict)'
            tGate = 0:1/self.pulseCal.samplingRate:self.gatedict.(gateName{1}).totalDuration;
            [iGateWaveforms.(gateName{1}), qGateWaveforms.(gateName{1})] ...
                = self.gatedict.(gateName{1}).uwWaveforms(tGate, 0);
        end
    end

    if isprop(self, 'gatedict2')
        iGateWaveforms2 = struct();
        qGateWaveforms2 = struct();
        for gateName = fieldnames(self.gatedict2)'
            tGate = 0:1/self.pulseCal2.samplingRate:self.gatedict2.(gateName{1}).totalDuration;
            [iGateWaveforms2.(gateName{1}), qGateWaveforms2.(gateName{1})] ...
                = self.gatedict2.(gateName{1}).uwWaveforms(tGate, 0);
        end
    end
    
    if isprop(self, 'fluxdict')
        iFluxWaveforms = struct();
        qFluxWaveforms = struct();
        for gateName = fieldnames(self.fluxdict)'
            tGate = 0:1/self.pulseCal.samplingRate:self.fluxdict.(gateName{1}).totalDuration;
            [iFluxWaveforms.(gateName{1}), qFluxWaveforms.(gateName{1})] ...
                = self.fluxdict.(gateName{1}).uwWaveforms(tGate, 0);
        end
    end
    %=================functions whose handles are used above===================
    % Set AWG waveforms
    function setgatewav(gateseq)
        if isprop(self, 'gatedict')
            % Use pre-calculated baseband waveforms if possible
            waveform1 = zeros(1, length(self.awgtaxis));
            waveform2 = zeros(1, length(self.awgtaxis));
            start = find(self.awgtaxis >= (self.seqEndTime - gateseq.totalDuration), 1);
            for col = 1:len(gateseq)
                % For each gate in the current sequence
                gate = gateseq.gateArray{col};
                if strcmp(gate.name, 'delay')
                    % If delay gate, skip to the start of next gate
                    start = start + length(0:1/self.pulseCal.samplingRate:gate.totalDuration) - 1;
                else
                    % Otherwise find pre-calculated baseband waveform by gate name
                    itemp = iGateWaveforms.(gate.name);
                    qtemp = qGateWaveforms.(gate.name);
                    % Update the corresponding segment in the waveform
                    stop = start + length(itemp) - 1;
                    waveform1(start:stop) = itemp;
                    waveform2(start:stop) = qtemp;
                    % Go to next gate
                    start = stop;
                end
            end
        else
            % Otherwise calculate waveforms from gateSequence object
            [waveform1, waveform2] ...
                = gateseq.uwWaveforms(self.awgtaxis, ...
                                      self.seqEndTime - gateseq.totalDuration);
        end
        if length(self.awgchannel{1}) == 2
            % I and Q => dual channel
            self.awg{1}.(self.awgchannel{1}{1}) = waveform1;
            self.awg{1}.(self.awgchannel{1}{2}) = waveform2;
        else
            if strfind(self.awgchannel{1}{1}, 'marker')
                % I => marker 
                self.awg{1}.(self.awgchannel{1}{1}) = double(waveform1 ~= 0);
            else
                % I => single channel
                self.awg{1}.(self.awgchannel{1}{1}) = waveform1;
            end
        end
    end

    function setgatewav2(gateseq2)
        if isprop(self, 'gatedict2')
            % Use pre-calculated baseband waveforms if possible
            waveform1 = zeros(1, length(self.awgtaxis));
            waveform2 = zeros(1, length(self.awgtaxis));
            start = find(self.awgtaxis >= (self.seqEndTime - gateseq2.totalDuration), 1);
            for col = 1:len(gateseq2)
                % For each gate in the current sequence
                gate = gateseq2.gateArray{col};
                if strcmp(gate.name, 'delay')
                    % If delay gate, skip to the start of next gate
                    start = start + length(0:1/self.pulseCal.samplingRate:gate.totalDuration) - 1;
                else
                    % Otherwise find pre-calculated baseband waveform by gate name
                    itemp = iGateWaveforms2.(gate.name);
                    qtemp = qGateWaveforms2.(gate.name);
                    % Update the corresponding segment in the waveform
                    stop = start + length(itemp) - 1;
                    waveform1(start:stop) = itemp;
                    waveform2(start:stop) = qtemp;
                    % Go to next gate
                    start = stop;
                end
            end
        else
            [waveform1, waveform2] ...
                = gateseq2.uwWaveforms(self.awgtaxis, ...
                                       self.seqEndTime - gateseq2.totalDuration);
        end
        if length(self.awgchannel{2}) == 2
            % Set dual channel with I and Q
            self.awg{2}.(self.awgchannel{2}{1}) = waveform1;
            self.awg{2}.(self.awgchannel{2}{2}) = waveform2; 
        else
            if strfind(self.awgchannel{2}{1}, 'marker')
                % I => marker 
                self.awg{2}.(self.awgchannel{2}{1}) = double(waveform1 ~= 0);
            else
                % I => single channel
                self.awg{2}.(self.awgchannel{2}{1}) = waveform1;
            end
        end
    end
    
    function setfluxwav(fluxseq)
        if isprop(self, 'fluxdict')
            % Use pre-calculated baseband waveforms if possible
            waveform1 = zeros(1, length(self.awgtaxis));
            waveform2 = zeros(1, length(self.awgtaxis));
            start = find(self.awgtaxis >= (self.seqEndTime - fluxseq.totalDuration), 1);
            for col = 1:len(fluxseq)
                % For each gate in the current sequence
                gate = fluxseq.gateArray{col};
                if strcmp(gate.name, 'delay')
                    % If delay gate, skip to the start of next gate
                    start = start + length(0:1/self.pulseCal.samplingRate:gate.totalDuration) - 1;
                else
                    % Otherwise find pre-calculated baseband waveform by gate name
                    itemp = iFluxWaveforms.(gate.name);
                    qtemp = qFluxWaveforms.(gate.name);
                    % Update the corresponding segment in the waveform
                    stop = start + length(itemp) - 1;
                    waveform1(start:stop) = itemp;
                    waveform2(start:stop) = qtemp;
                    % Go to next gate
                    start = stop;
                end
            end
        else
            [waveform1, waveform2] ...
                = fluxseq.uwWaveforms(self.awgtaxis, ...
                                      self.seqEndTime - fluxseq.totalDuration);
        end
        if length(self.awgchannel{3}) == 2
            % Set dual channel with I and Q
            self.awg{3}.(self.awgchannel{3}{1}) = waveform1;
            self.awg{3}.(self.awgchannel{3}{2}) = waveform2; 
        else
            if strfind(self.awgchannel{3}{1}, 'marker')
                % I => marker 
                self.awg{3}.(self.awgchannel{3}{1}) = double(waveform1 ~= 0);
            else
                % I => single channel
                self.awg{3}.(self.awgchannel{3}{1}) = waveform1;
            end
        end
    end

    % Start generation for AWG
    function startawg1(~)
        pulsegen1.Generate();
    end
    function startawg2(~)
        pulsegen2.Generate();
    end
end