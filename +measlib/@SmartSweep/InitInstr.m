function InitInstr(self)

    global rfgen specgen logen specgen2 fluxgen ...
           yoko1 yoko2 pulsegen1 pulsegen2 card triggen;
    
    % Init rfgen
    if ~isempty(self.rffreq)
        rfgen.SetFreq(self.rffreq(1));
        rfgen.PowerOn();
    else
        try
            rfgen.PowerOff();
        catch
        end
    end
    
    if ~isempty(self.rfpower)
        rfgen.SetPower(self.rfpower(1));
    end
    
    if ~isempty(self.rfphase)
        rfgen.SetPhase(self.rfphase(1));
    end
      
    if self.rfcw == 1
        rfgen.ModOff();
    elseif self.rfcw == 0
        rfgen.ModOn();
    end
    
    % Init specgen
    if ~isempty(self.specfreq)
        specgen.SetFreq(self.specfreq(1));
        specgen.PowerOn();
    else
        try
            specgen.PowerOff();
        catch
        end
    end
    
    if ~isempty(self.specpower)
        specgen.SetPower(self.specpower(1));
    end
    
    if ~isempty(self.specphase)
        specgen.SetPhase(self.specphase(1));
    end
    
    if self.speccw == 1
        specgen.ModOff();
    elseif self.speccw == 0
        specgen.ModOn();
    end
    
    % Init logen
    if ~isempty(self.intfreq)
        logen.SetFreq(self.rffreq(1)+self.intfreq(1));
        logen.ModOff();
        logen.PowerOn();
    else
        try
            logen.PowerOff();
        catch
        end
    end
    
    if ~isempty(self.lopower)
        logen.SetPower(self.lopower(1));
    end
    
    if ~isempty(self.lophase)
        logen.SetPhase(self.lophase(1));
    end

    % Init specgen2
    if ~isempty(self.spec2freq)
        specgen2.SetFreq(self.spec2freq(1));
        specgen2.PowerOn();
    else
        try
            specgen2.PowerOff();
        catch
        end
    end
    
    if ~isempty(self.spec2power)
        specgen2.SetPower(self.spec2power(1));
    end
    
    if ~isempty(self.spec2phase)
        specgen2.SetPhase(self.spec2phase(1));
    end
    
    if self.spec2cw == 1
        specgen2.ModOff();
    elseif self.spec2cw == 0
        specgen2.ModOn();
    end
    
    % Init fluxgen
    if ~isempty(self.fluxfreq)
        fluxgen.SetFreq(self.fluxfreq(1));
        fluxgen.PowerOn();
    else
        try
            fluxgen.PowerOff();
        catch
        end
    end
    
    if ~isempty(self.fluxpower)
        fluxgen.SetPower(self.fluxpower(1));
    end
    
    if ~isempty(self.fluxphase)
        fluxgen.SetPhase(self.fluxphase(1));
    end
    
    if self.fluxcw == 1
        fluxgen.ModOff();
    elseif self.fluxcw == 0
        fluxgen.ModOn();
    end
    
    % Init yoko1
    if ~isempty(self.yoko1volt)
        yoko1.SetVoltage(self.yoko1volt(1));
    end
    
    % Init yoko2
    if ~isempty(self.yoko2volt)
        yoko2.SetVoltage(self.yoko1volt(1));
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
              	self.seqEndTime-self.gateseq(1).totalDuration);
    end
    if ~isempty(self.measpulse)
        [pulsegen2.waveform1, ~] ...
            = self.measpulse.uwWaveforms(self.awgtaxis, self.measStartTime);
    end
    if ~isempty(self.fluxseq)
        [pulsegen2.waveform2, ~] ...
            = self.fluxseq(1).uwWaveforms(self.awgtaxis, ...
                self.seqEndTime-self.fluxseq(1).totalDuration);
    end
    
    pulsegen1.mkr1offset = -64;
    pulsegen1.mkr2offset = -64;
    pulsegen2.mkr2offset = -64;    
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
        if self.rfcw == 1
        % Default value for CW measurement
            acqtime = self.autocardacqtime;
        elseif self.rfcw == 0
        % Default value for pulsed measurement
            acqtime = round(self.measpulse.totalDuration/1e-6)*1e-6 + 1e-6;
        end
    else
        acqtime = self.cardacqtime;
    end
    % Trigger period
    if strcmp(self.trigperiod, 'auto')
        if self.rfcw == 1
        % Default value for CW measurement
            trigperiod = self.autotrigperiod;
        elseif self.rfcw == 0
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