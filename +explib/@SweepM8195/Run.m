function Run(self)
    % Run experiment and acquire data
    
    global card triggen;
    
    % Set up acquistion card
    cardparams = card.GetParams();
    cardparams.averages = self.cardAverages;
    cardparams.segments = length(self.playlist);
    
    if self.histogram
        % Histogram is for single shot
        % So turn off averaging
        cardparams.averages = 1;
        % and turn on multi-segment 
        cardparams.segments = length(self.playlist)*self.cardAverages;
    end
    
    if ~isempty(self.cavityFreq) && ~self.cavitybaseband && isempty(self.lochannel)
        % Sweep cavity frequency && direct synthesis && external LO
        % Needs to run single playlist while sweep LO generator
        cardparams.segments = length(self.playlist)/length(self.cavityFreq);
    end
    
    cardparams.delaytime = self.measStartTime + self.pulseCal.cardDelayOffset;
    cardparams.trigPeriod = triggen.period;
    card.SetParams(cardparams);
    
    display(['Running ', self.experimentName, ' ...']);
    
    % Clear result
    self.result = struct();
    % Generator filename for saving data
    self.savefile = [self.experimentName, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];
    
    % Run experiment
    if ~isempty(self.cavityFreq) && (self.cavitybaseband || isempty(self.lochannel))
        % Sweep cavity frequency && (upconversion || external LO)
        self.RunCavitySweep();
    elseif self.histogram
        % Single shot histogram
        self.RunHistogram();
    else
        % All other cases are handled in RunGateSweep(),
        % including cavity/qubit frequency sweep in direct synthesis mode
        % because they run in the same way as gate sequence sweep
        self.RunGateSweep();
    end
    
    display(['Experiment ', self.experimentName, ' finished.']);
    
    % Auto save data
    if self.autosave
        self.Save();
    end
end