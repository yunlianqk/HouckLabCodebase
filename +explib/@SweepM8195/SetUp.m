function SetUp(self)

    % Set up pulses
    self.measurement = self.pulseCal.measurement();
    % self.sequences should already be created at this stage,
    % typically by SetUp() method in subclasses
    if self.normalization
        % Append Identity and X180 as last two sequences for normalization
        self.sequences(end+1) = pulselib.gateSequence(self.pulseCal.Identity());
        self.sequences(end+1) = pulselib.gateSequence(self.pulseCal.X180());
    end
    % Calculate pulse timing parameters
    self.sequenceEndTime = self.pulseCal.startBuffer + max([self.sequences.totalSequenceDuration]);
    self.measStartTime = self.sequenceEndTime + self.pulseCal.measBuffer;
    self.waveformEndTime = self.measStartTime + self.measurement.totalDuration + self.pulseCal.endBuffer;
    
    % Set up external generators it they are used
    global rfgen logen;
    
    if self.cavitybaseband
        if ~isempty(self.cavityFreq)
            rfgen.freq = self.cavityFreq(1);
        else
            rfgen.freq = self.pulseCal.cavityFreq;
        end
        rfgen.power = self.pulseCal.rfPower;
        % Modulation is in 'pulse mode' (signal goes to FRONT of E8267D)
        % IQ wideband modulation (BACK of E8267D) is turned OFF
        rfgen.modulation = 1;
        rfgen.pulse = 1;
        rfgen.iq = 0;
        rfgen.alc = 1;
        rfgen.output = 1;
        self.pulseCal.cavityAmplitude = 1;
    else
        try
            rfgen.output = 0;
        catch
        end
    end
    
    if isempty(self.lochannel)
        if ~isempty(self.cavityFreq)
            logen.freq = self.cavityFreq(1)+self.pulseCal.intFreq;
        else
            logen.freq = self.pulseCal.cavityFreq+self.pulseCal.intFreq;
        end
        logen.power = self.pulseCal.loPower;
        logen.modulation = 0;
        logen.alc = 1;
        logen.output = 1;
    else
        try
            logen.output = 0;
        catch
        end
    end
end