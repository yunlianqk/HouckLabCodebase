function SetSweep(self)

    global rfgen specgen logen yoko1 pulsegen1 pulsegen2;

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
    pName = {'rffreq', 'lofreq', 'rfpower', ...
             'specfreq', 'specpower', 'yoko1volt', ...
             'gateseq', 'fluxseq'};
    fHdle = {@rfgen.SetFreq, @logen.SetFreq, @rfgen.SetPower, ...
             @specgen.SetFreq, @specgen.SetPower, @yoko1.SetVoltage, ...
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
    % Set function handles for starting AWGs
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
%=================functions whose handles are used above===================
    % Set AWG waveforms and start generation
    function setgatewav(gateseq)
        [pulsegen1.waveform1, pulsegen1.waveform2] ...
            = gateseq.uwWaveforms(self.awgtaxis, ...
                                  self.seqEndTime-gateseq.totalSequenceDuration);
    end
    function setfluxwav(fluxseq)
        [pulsegen2.waveform2, ~] ...
            = fluxseq.uwWaveforms(self.awgtaxis, ...
                                  self.seqEndTime-fluxseq.totalSequenceDuration);
    end
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
    function startawg1(~)
        pulsegen1.Generate();
    end
    function startawg2(~)
        pulsegen2.Generate();
    end
end