function Download(self)

    global awg;

    if self.normalization
        self.sequences(end+1) = pulselib.gateSequence(self.pulseCal.Identity());
        self.sequences(end+1) = pulselib.gateSequence(self.pulseCal.X180());
    end    
    self.sequenceEndTime = self.pulseCal.startBuffer + max([self.sequences.totalSequenceDuration]);
    self.measStartTime = self.sequenceEndTime + self.pulseCal.measBuffer;
    self.waveformEndTime = self.measStartTime + self.measurement.totalDuration + self.pulseCal.endBuffer;

    % clear awg of segments
    iqseq('delete', [], 'keepOpen', 1);
    % check # segments won't be too large
    if (length(self.sequences) > awg.maxSegNumber) ...
       || (length(self.qubitFreq) > awg.maxSegNumber) ...
       || (length(self.cavityFreq) > awg.maxSegNumber)
        error(['Waveform library size exceeds maximum segment number ', int2str(awg.maxSegNumber)]);
    end

    % set up time axis and make sure it's correct length for awg
    segsize = ceil(self.waveformEndTime*awg.samplerate/awg.granularity)*awg.granularity;
    % check if too short
    if segsize < awg.minSegSize
        error(['Time axis is shorter than minimum segment size ', int2str(awg.minSegSize)]);
    end
    % check if too long
    if segsize > awg.maxSegSize
        error(['Time axis is larger than maximum segment size ', int2str(awg.maxSegSize)]);
    end

    self.playlist = struct();
    if ~isempty(self.qubitFreq)
        self.LoadQubitSweep(segsize);
    elseif ~isempty(self.cavityFreq)
        self.LoadCavitySweep(segsize);
    else
        self.LoadGateSweep(segsize);
    end
end