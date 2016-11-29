function Run(self)

    global card triggen;

    cardparams = card.GetParams();
    if self.histogram
        cardparams.averages = 1;
        cardparams.segments = length(self.playlist)*self.cardAverages;
    else
        cardparams.averages = self.cardAverages;
        cardparams.segments = length(self.playlist);
    end
    cardparams.delaytime = self.measStartTime + self.pulseCal.cardDelayOffset;
    cardparams.trigPeriod = triggen.period;
    card.SetParams(cardparams);
    
    display(['Running ', self.experimentName, ' ...']);
    
    self.result = struct();
    if self.cavitybaseband && ~isempty(self.cavityFreq)
        self.RunCavitySweep();
    elseif self.histogram
        self.RunHistogram();
    else
        self.RunGateSweep();
    end
    
    display(['Experiment ', self.experimentName, ' finished.']);
    
    if self.autosave
        self.Save();
    end
end