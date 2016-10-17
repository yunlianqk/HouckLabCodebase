function InitInstr(self)

    global rfgen specgen logen yoko1 pulsegen1 pulsegen2 card triggen;
    
    % Init rfgen
    if ~isempty(self.rffreq)
        rfgen.SetFreq(self.rffreq(1));
        rfgen.PowerOn();
    else
        rfgen.PowerOff();
    end
    
    if ~isempty(self.rfpower)
        rfgen.SetPower(self.rfpower(1));
    end
    
    if ~isempty(self.rfphase)
        rfgen.SetPhase(self.rfphase(1));
    end
      
    if self.rfcw
        rfgen.ModOff();
    else
        rfgen.ModOn();
    end
    
    % Init specgen
    if ~isempty(self.specfreq)
        specgen.SetFreq(self.specfreq(1));
        specgen.PowerOn();
    else
        specgen.PowerOff();
    end
    
    if ~isempty(self.specpower)
        specgen.SetPower(self.specpower(1));
    end
    
    if ~isempty(self.specphase)
        specgen.SetPhase(self.specphase(1));
    end
    
    if self.speccw
        specgen.ModOff();
    else
        specgen.ModOn();
    end
    
    % Init logen
    if ~isempty(self.intfreq)
        logen.SetFreq(self.rffreq(1)+self.intfreq(1));
        logen.ModOff();
        logen.PowerOn();
    else
        logen.PowerOff();
    end
    
    if ~isempty(self.lopower)
        logen.SetPower(self.lopower(1));
    end
    
    if ~isempty(self.lophase)
        logen.SetPhase(self.lophase(1));
    end
    
    % Init yoko
    if ~isempty(self.yoko1volt)
        yoko1.SetVoltage(self.yoko1volt(1));
    end
    
    % Init pulsegen1 and pulsegen2
    if ~isempty(self.awgtaxis)
        pulsegen1.timeaxis = self.awgtaxis;
        pulsegen2.timeaxis = self.awgtaxis;
        pulsegen1.waveform1 = zeros(1, length(self.awgtaxis));
        pulsegen1.waveform2 = zeros(1, length(self.awgtaxis));
        pulsegen2.waveform1 = zeros(1, length(self.awgtaxis));
        pulsegen2.waveform2 = zeros(1, length(self.awgtaxis));
    end
    
    if ~isempty(self.gateseq)
        [pulsegen1.waveform1, pulsegen1.waveform2] ...
            = self.gateseq(1).uwWaveforms(self.awgtaxis, ...
              	self.seqEndTime-self.gateseq(1).totalSequenceDuration);
    end
    if ~isempty(self.measpulse)
        [pulsegen2.waveform1, ~] ...
            = self.measpulse.uwWaveforms(self.awgtaxis, self.measStartTime);
    end
    if ~isempty(self.fluxseq)
        [pulsegen2.waveform2, ~] ...
            = self.fluxseq(1).uwWaveforms(self.awgtaxis, ...
                self.seqEndTime-self.fluxseq(1).totalSequenceDuration);
    end
    
    if ~isempty(self.awgch1)
        pulsegen1.waveform1 = self.awgch1(1, :);
    end
    if ~isempty(self.awgch2)
        pulsegen1.waveform2 = self.awgch2(1, :);
    end
    if ~isempty(self.awgch3)
        pulsegen2.waveform1 = self.awgch3(1, :);
    end
    if ~isempty(self.awgch4)
        pulsegen2.waveform2 = self.awgch4(1, :);
    end
    
    pulsegen1.mkr1offset = -64;
    pulsegen1.mkr2offset = -64;
    pulsegen1.Generate();
    pulsegen2.Generate();
    
    % Init card
    cardparams = card.GetParams();
    % Delay time
    if self.rfcw
        % Default value for CW measurement
        delaytime = self.autocarddelay;
    else
        % Default value for pulsed measurement
        delaytime = self.measStartTime;
    end
    delaytime = delaytime + self.carddelayoffset;
    % Acquisition time
    if strcmp(self.cardacqtime, 'auto')
        if self.rfcw
        % Default value for CW measurement
            acqtime = self.autocardacqtime;
        else
        % Default value for pulsed measurement
            acqtime = round(self.measpulse.totalDuration/1e-6)*1e-6 + 1e-6;
        end
    else
        acqtime = self.cardacqtime;
    end
    % Trigger period
    if strcmp(self.trigperiod, 'auto')
        if self.rfcw
        % Default value for CW measurement
            trigperiod = self.autotrigperiod;
        else
    % Default value for pulsed measurement
            trigperiod = max(ceil(self.waveformEndTime/1e-6+1)*1e-6, ...
                             round((delaytime+acqtime)/1e-6)*1e-6+4e-6);
        end
    else
        trigperiod = self.trigperiod;
    end
    cardparams.averages = self.cardavg;
    cardparams.segments = 1;
    cardparams.delaytime = delaytime;
    cardparams.samples = round(acqtime/cardparams.sampleinterval);
    cardparams.trigPeriod = trigperiod;
    card.SetParams(cardparams);
    
    % Init triggen
    triggen.SetPeriod(trigperiod);
    triggen.PowerOn();
end