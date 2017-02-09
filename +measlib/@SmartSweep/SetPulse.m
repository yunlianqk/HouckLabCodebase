function SetPulse(self)

    global pulsegen1;
    
    seqDuration = 0;
    measDuration = 0;
    self.pulseCal.samplingRate = pulsegen1.samplingrate;

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
        seqDuration = max([self.gateseq.totalSequenceDuration]);
    catch
    end
    
    try
        seqDuration = max(seqDuration, ...
                          max([self.fluxseq.totalSequenceDuration]));
    catch
    end
    
    try
        measDuration = self.measpulse.totalDuration;
    catch
    end
    
    self.seqEndTime = self.startBuffer + seqDuration;
    self.measStartTime = self.seqEndTime + self.measBuffer;
    self.waveformEndTime = self.measStartTime + measDuration + self.endBuffer;
    if isempty(self.awgch1) || isempty(self.awgch2) ...
       || isempty(self.awgch3) || isempty(self.awgch4)
        self.awgtaxis = 0:1/pulsegen1.samplingrate:self.waveformEndTime;
    end
end