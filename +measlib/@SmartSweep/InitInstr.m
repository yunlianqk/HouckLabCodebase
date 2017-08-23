function InitInstr(self)

    global rfgen specgen logen rfgen2 specgen2 logen2 fluxgen ...
           yoko1 yoko2 pulsegen1 pulsegen2 card triggen;

    % Initialize generators
    function inuse = isused(gen)
        % Determine if gen is in self.generator
        inuse = 0;
        for ii = 1:length(self.generator)
            if gen == self.generator{ii}
                inuse = 1;
                return;
            end
        end
    end

    gen = {rfgen, specgen, rfgen2, specgen2, fluxgen, logen, logen2};
    prefix = {'rf', 'spec', 'rf2', 'spec2', 'flux', 'lo', 'lo2'};
    for index = 1:length(gen)
        % Set frequency
        if ~isempty(self.([prefix{index}, 'freq'])) && isused(gen{index})
            gen{index}.SetFreq(self.([prefix{index}, 'freq'])(1));
            gen{index}.ModOff();
            gen{index}.PowerOn();
        else
            try
                gen{index}.PowerOff();
            catch
            end
        end
        % Set power
        if ~isempty(self.([prefix{index}, 'power'])) && isused(gen{index})
            gen{index}.SetPower(self.([prefix{index}, 'power'])(1));
        end
        % Set phase
        if ~isempty(self.([prefix{index}, 'phase'])) && isused(gen{index})
            gen{index}.SetPhase(self.([prefix{index}, 'freq'])(1));
        end
    end
    
    % Set modulation on if pulse sequence exists
    % Leave index == 6 as empty because self.generator{6} corresponds to logen
    % which is always in CW
    seq = {self.gateseq, self.gateseq2, self.fluxseq, self.measseq, [], self.measseq2};
    awgchannel = {self.awgchannel{1:4}, [], self.awgchannel{5}};
    for index = 1:length(seq)
        if ~isempty(seq{index}) && ~isempty(self.generator{index})
            self.generator{index}.ModOn();
            if strfind(awgchannel{index}{1}, 'marker')
                % If using marker for pulse modulation, turn off wideband IQ
                self.generator{index}.iq = 0;
            end
        end
    end
    
    % Initialize yoko's
    yoko = {yoko1, yoko2};
    prefix = {'yoko1', 'yoko2'};
    for index = 1:length(yoko)
        if ~isempty(self.([prefix{index}, 'volt']))
            yoko{index}.SetVoltage(self.([prefix{index}, 'volt'])(1));
        end
    end
    
    % Initialize pulsegen1 and pulsegen2
    if ~isempty(self.awgtaxis)
        pulsegen1.timeaxis = self.awgtaxis;
        pulsegen2.timeaxis = self.awgtaxis;
        pulsegen1.waveform1 = zeros(1, length(self.awgtaxis));
        pulsegen1.waveform2 = zeros(1, length(self.awgtaxis));
        pulsegen2.waveform1 = zeros(1, length(self.awgtaxis));
        pulsegen2.waveform2 = zeros(1, length(self.awgtaxis));
    end
    % Pass waveforms to AWG channels according to channel routing
    seq = {self.gateseq, self.gateseq2, self.fluxseq, self.measseq, self.measseq2};
    for index = 1:length(seq)
        if ~isempty(seq{index})
            % Generate waveforms
            if index < 4
                % Drive pulses
                [waveform1, waveform2] ...
                    = seq{index}(1).uwWaveforms(self.awgtaxis, ...
                                                self.seqEndTime - seq{index}(1).totalDuration);
            else
                % Measurement pulses
                [waveform1, waveform2] ...
                    = seq{index}(1).uwWaveforms(self.awgtaxis, self.measStartTime);
            end
            % Load waveforms to AWG
            if length(self.awgchannel{index}) == 2
                % I and Q => channel 1 and 2
                self.awg{index}.(self.awgchannel{index}{1}) = waveform1;
                self.awg{index}.(self.awgchannel{index}{2}) = waveform2;
            else
                if strfind(self.awgchannel{index}{1}, 'marker')
                    % I => marker 
                    self.awg{index}.(self.awgchannel{index}{1}) = double(waveform1 ~= 0);
                else
                    % I => single channel
                    self.awg{index}.(self.awgchannel{index}{1}) = waveform1;
                end
            end
        end
    end
    % Turn on AWGs
    pulsegen1.Generate();
%     pulsegen2.Generate();

    % Initialize card
    cardparams = card.GetParams();
    % Delay time
    if isempty(self.measseq) && isempty(self.measseq2)
        % Default value for CW measurement
        delaytime = self.autocarddelay;
    else
        % Default value for pulsed measurement
        delaytime = self.measStartTime;
    end
    delaytime = delaytime + self.carddelayoffset;
    % Acquisition time
    if strcmp(self.cardacqtime, 'auto')
        if isempty(self.measseq)
        % Default value for CW measurement
            acqtime = self.autocardacqtime;
        else
        % Default value for pulsed measurement
            acqtime = round(self.measseq.totalDuration/1e-6)*1e-6 + 1e-6;
        end
    else
        acqtime = self.cardacqtime;
    end
    % Trigger period
    if strcmp(self.trigperiod, 'auto')
        if isempty(self.measseq)
        % Default value for CW measurement
            trigperiod = self.autotrigperiod;
        else
        % Default value for pulsed measurement
            trigperiod = max(ceil(self.waveformEndTime/1e-6+1)*1e-6, ...
                             round((delaytime+acqtime)/1e-6)*1e-6+4e-6);
        end
    else
        trigperiod = self.trigperiod;
        if trigperiod < self.waveformEndTime
            disp('Warning: Trigger period is shorter than pulse length.');
        end
    end
    cardparams.averages = self.cardavg;
    cardparams.segments = self.cardseg;
    cardparams.delaytime = delaytime;
    cardparams.samples = round(acqtime/cardparams.sampleinterval);
    cardparams.trigPeriod = trigperiod;
    card.SetParams(cardparams);
    
    % Initialize triggen
    triggen.SetPeriod(trigperiod);
    triggen.PowerOn();
end
