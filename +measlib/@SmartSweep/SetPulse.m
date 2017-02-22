function SetPulse(self)

    global pulsegen1;
    
    seqDuration = 0;
    measDuration = 0;
    
    if ~isempty(self.pulseCal)
        self.pulseCal.samplingRate = pulsegen1.samplingrate;
    end

    if isempty(self.measpulse) && ~isempty(self.pulseCal)
        self.measpulse = self.pulseCal.measurement();
    end
    
    if ~isempty(self.gateseq) && ~isa(self.gateseq, 'pulselib.gateSequence')
        % Check data type of gateseq
        error('gateseq must be a gateSequence object.')
    end
    if ~isempty(self.fluxseq) && ~isa(self.fluxseq, 'pulselib.gateSequence')
        % Check data type of fluxseq
            error('fluxseq must be a gateSequence object.')
    end
    if ~isempty(self.measpulse) && ~isa(self.measpulse, 'pulselib.measPulse');
        % Check data type of measpulse
        error('measpulse must be a measPulse object.');
    end

    % Append Identity and X180 as last two sequences for normalization
    if self.normalization
        self.gateseq(end+1) = pulselib.gateSequence(self.pulseCal.Identity());
        self.gateseq(end+1) = pulselib.gateSequence(self.pulseCal.X180());
        if ~isempty(self.fluxseq)
            self.fluxseq(end+1) = pulselib.gateSequence(self.pulseCal.Identity());
            self.fluxseq(end+1) = pulselib.gateSequence(self.pulseCal.Identity());
        end
    end
    
    try
        seqDuration = max([self.gateseq.totalDuration]);
    catch
    end
    
    try
        seqDuration = max(seqDuration, ...
                          max([self.fluxseq.totalDuration]));
    catch
    end
    
    try
        measDuration = self.measpulse.totalDuration;
    catch
    end
    
    self.seqEndTime = self.startBuffer + seqDuration;
    self.measStartTime = self.seqEndTime + self.measBuffer;
    self.waveformEndTime = self.measStartTime + measDuration + self.endBuffer;
    self.awgtaxis = 0:1/pulsegen1.samplingrate:self.waveformEndTime;
    
    % Update generator cw flag
    if ~isempty(self.measpulse)
        self.rfcw = 0;
    elseif ~isempty(self.rffreq)
        self.rfcw = 1;
    end
    
    if ~isempty(self.gateseq)
        self.speccw = 0;
    elseif ~isempty(self.specfreq)
        self.speccw = 1;
    end
    
    if ~isempty(self.fluxseq)
        self.fluxcw = 0;
    elseif ~isempty(self.fluxfreq)
        self.fluxcw = 1;
    end
end