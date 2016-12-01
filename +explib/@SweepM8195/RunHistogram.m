function RunHistogram(self)

    global awg card;
    
    cardparams = card.GetParams();
    intStart = self.pulseCal.integrationStartIndex;
    intStop = self.pulseCal.integrationStopIndex;
    numsegs = length(self.playlist);
    if isempty(self.numbins)
        numbins = 100;
    else
        numbins = self.numbins;
    end
    self.result.AmpCounts = zeros(numsegs, numbins);
    self.result.PhaseCounts = zeros(numsegs, numbins);
    % If histrange is not specified,
    % Do trial run to get the rough range of readout amplitude
    % Histogram bins are generated based on the result
    if isempty(self.histrange)
        awg.SeqStop(self.playlist);
        card.WaitTrigger();
        awg.SeqRun(self.playlist);
        [Idata, Qdata] = card.ReadIandQ();
        if (self.pulseCal.intFreq == 0) 
            Adata = sqrt(mean(Idata(:, intStart:intStop).^2 ... 
                              + Qdata(:, intStart:intStop).^2, 2))';
            Pdata = unwrap(atan2(mean(Qdata(:, intStart:intStop), 2), ...
                                 mean(Idata(:, intStart:intStop), 2))');

        else
            [Adata, Pdata] ...
                = funclib.Demodulate(1/cardparams.samplerate, ...
                                     Idata(:, intStart:intStop), ...
                                     self.pulseCal.intFreq);
        end
        self.result.AmpEdges = linspace(min(min(Adata)), max(max(Adata)), numbins+1);
        self.result.PhaseEdges = linspace(min(min(Pdata)), max(max(Pdata)), numbins+1);
    else
        self.result.AmpEdges = linspace(self.histrange(1), self.histrange(2), numbins+1);
        self.result.PhaseEdges = linspace(self.histrange(3), self.histrange(4), numbins+1);
    end
    
    % Main loop that updates histcounts
    for ind = 1:self.softwareAverages
        awg.SeqStop(self.playlist);
        card.WaitTrigger();
        awg.SeqRun(self.playlist);
        [Idata, Qdata] = card.ReadIandQ();
        if (self.pulseCal.intFreq == 0) 
            Adata = sqrt(mean(Idata(:, intStart:intStop).^2 ... 
                              + Qdata(:, intStart:intStop).^2, 2))';
            Pdata = unwrap(atan2(mean(Qdata(:, intStart:intStop), 2), ...
                                 mean(Idata(:, intStart:intStop), 2))');

        else
            [Adata, Pdata] ...
                = funclib.Demodulate(1/cardparams.samplerate, ...
                                     Idata(:, intStart:intStop), ...
                                     self.pulseCal.intFreq);
        end
        for seg = 1:numsegs
            [AmpCounts, ~] = histcounts(Adata(seg:numsegs:end), self.result.AmpEdges);
            self.result.AmpCounts(seg, :) = self.result.AmpCounts(seg, :) + AmpCounts;
            [PhaseCounts, ~] = histcounts(Pdata(seg:numsegs:end), self.result.PhaseEdges);
            self.result.PhaseCounts(seg, :) = self.result.PhaseCounts(seg, :) + PhaseCounts;
        end
        
        if self.doPlot && ~mod(ind, self.updatePlot)
            figure(10);
            subplot(2, 1, 1);
            plot(self.result.AmpEdges(2:end), self.result.AmpCounts);
            title(['SoftAvg ', num2str(ind), ' of ', num2str(self.softwareAverages)]);
            subplot(2, 1, 2);
            plot(self.result.PhaseEdges(2:end), self.result.PhaseCounts);
            drawnow;
        end
    end
    
    self.PlotHistogram();
end