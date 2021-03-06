function SetPulse(self)

    global pulsegen1;
    
    seqDuration = 0;
    measDuration = 0;
    tomoSeqInd = self.tomoSeqInd;
    if ~isempty(self.pulseCal)
        self.pulseCal.samplingRate = pulsegen1.samplingrate;
        if ~isempty(self.generator{4})
            self.measseq = pulselib.gateSequence(self.pulseCal.measurement());
        end
    end
    
    if ~isempty(self.pulseCal2)
        self.pulseCal2.samplingRate = pulsegen1.samplingrate;
        if ~isempty(self.generator{6})
            self.measseq2 = pulselib.gateSequence(self.pulseCal2.measurement());
        end
    end
    
    for seq = {self.gateseq, self.gateseq2, self.fluxseq, self.measseq, self.measseq2}
        checkpulse(seq{:});
    end

    % Append Identity X90 and Y90 at the end of sequences for tomography
    
    if self.tomography
        disp(['Using the final state of row ',num2str(tomoSeqInd),' of gatesequences for Tomography']);
        if ~isempty(self.gateseq)
            self.gateseq(end+1) = pulselib.gateSequence(self.gateseq(tomoSeqInd).gateArray);
            self.gateseq(end).append(self.pulseCal.Identity());
            self.gateseq(end+1) = pulselib.gateSequence(self.gateseq(tomoSeqInd).gateArray);
            self.gateseq(end).append(self.pulseCal.X90());
            self.gateseq(end+1) = pulselib.gateSequence(self.gateseq(tomoSeqInd).gateArray);
            self.gateseq(end).append(self.pulseCal.Y90());        
        end
        if ~isempty(self.gateseq2)
            self.gateseq2(end+1) = pulselib.gateSequence(self.gateseq2(tomoSeqInd).gateArray);
            self.gateseq2(end).append(self.pulseCal2.Identity());
            self.gateseq2(end+1) = pulselib.gateSequence(self.gateseq2(tomoSeqInd).gateArray);
            self.gateseq2(end).append(self.pulseCal2.X90());
            self.gateseq2(end+1) = pulselib.gateSequence(self.gateseq2(tomoSeqInd).gateArray);
            self.gateseq2(end).append(self.pulseCal2.Y90());
        end
        if ~isempty(self.fluxseq)
            self.fluxseq(end+1) = pulselib.gateSequence(self.fluxseq(tomoSeqInd).gateArray);
            self.fluxseq(end).append(self.pulseCal2.Identity());
            self.fluxseq(end+1) = pulselib.gateSequence(self.fluxseq(tomoSeqInd).gateArray);
            self.fluxseq(end).append(self.pulseCal2.Identity());
            self.fluxseq(end+1) = pulselib.gateSequence(self.fluxseq(tomoSeqInd).gateArray);
            self.fluxseq(end).append(self.pulseCal2.Identity());
        end
    end
    
    % Append Identity and X180 as last two sequences for normalization
    if self.normalization
        if ~isempty(self.gateseq)
            self.gateseq(end+1) = pulselib.gateSequence(self.pulseCal.Identity());
            self.gateseq(end+1) = pulselib.gateSequence(self.pulseCal.X180());
        end
        if ~isempty(self.gateseq2)
            self.gateseq2(end+1) = pulselib.gateSequence(self.pulseCal2.Identity());
            self.gateseq2(end+1) = pulselib.gateSequence(self.pulseCal2.X180());
        end
        if ~isempty(self.fluxseq)
            self.fluxseq(end+1) = pulselib.gateSequence(self.pulseCal.Identity());
            self.fluxseq(end+1) = pulselib.gateSequence(self.pulseCal.Identity());
        end
    end
    
    % Get the duration of the longest sequence
    try
        seqDuration = max([self.gateseq.totalDuration]);
    catch
    end
    
    try
        seqDuration = max(seqDuration, max([self.gateseq2.totalDuration]));
    catch
    end
        
    try
        seqDuration = max(seqDuration, max([self.fluxseq.totalDuration]));
    catch
    end
    % Get the duration of measurement pulse
    try
        measDuration = self.measseq.totalDuration;
    catch
    end
    try
        measDuration = max(measDuration, self.measseq2.totalDuration);
    catch
    end
    % Calculate the timing parameters
    self.seqEndTime = self.startBuffer + seqDuration;
    self.measStartTime = self.seqEndTime + self.measBuffer;
    self.waveformEndTime = self.measStartTime + measDuration + self.endBuffer;
    self.awgtaxis = 0:1/pulsegen1.samplingrate:self.waveformEndTime;
    
    function checkpulse(sequence)
         if ~isempty(sequence) && isempty(strfind(class(sequence), 'pulselib'))
             error([inputname(1), ' must be a pulselib object.']);
         end
    end
end
