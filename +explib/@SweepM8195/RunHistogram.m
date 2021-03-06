function RunHistogram(self)
    % Send AWG sequences and get single shot histogram
    
    global awg card;
    
    cardparams = card.GetParams();
    intStart = self.pulseCal.integrationStartIndex;
    intStop = self.pulseCal.integrationStopIndex;
    numsegs = length(self.playlist);
    
    % Pre-allocate arrays to store results
    if isempty(self.numbins)
        numbins = 100;
    else
        numbins = self.numbins;
    end
    self.result.AmpCounts = zeros(numsegs, numbins);
    self.result.PhaseCounts = zeros(numsegs, numbins);
    
    if isempty(self.histrange)
        % If histrange is not specified,
        % Do trial run to get the rough range
        % Histogram bins are generated based on the result
        awg.SeqStop(self.playlist);
        card.WaitTrigger();
        awg.SeqRun(self.playlist);
        [Idata, Qdata] = card.ReadIandQ();
        if (self.pulseCal.intFreq == 0)
            % Homodyne
            % Amplitude
            Adata = sqrt(mean(Idata(:, intStart:intStop).^2 ... 
                              + Qdata(:, intStart:intStop).^2, 2))';
            % Phase
            Pdata = unwrap(atan2(mean(Qdata(:, intStart:intStop), 2), ...
                                 mean(Idata(:, intStart:intStop), 2))');

        else
            % Heterodyne
            [Adata, Pdata] ...
                = funclib.Demodulate(1/cardparams.samplerate, ...
                                     Idata(:, intStart:intStop), ...
                                     self.pulseCal.intFreq);
        end
        % Generate bin edges
        self.result.AmpEdges = linspace(min(min(Adata)), max(max(Adata)), numbins+1);
        self.result.PhaseEdges = linspace(min(min(Pdata)), max(max(Pdata)), numbins+1);
    else
        % If histrange is specified, generate bin edges accordingly
        self.result.AmpEdges = linspace(self.histrange(1), self.histrange(2), numbins+1);
        self.result.PhaseEdges = linspace(self.histrange(3), self.histrange(4), numbins+1);
    end
    
    % Main (software averaging) loop that updates histcounts
    for ind = 1:self.softwareAverages
        % Start AWG and acquire data
        awg.SeqStop(self.playlist);
        card.WaitTrigger();
        awg.SeqRun(self.playlist);
        [Idata, Qdata] = card.ReadIandQ();
        if (self.pulseCal.intFreq == 0)
            % Homodyne
            % Amplitude
            Adata = sqrt(mean(Idata(:, intStart:intStop).^2 ... 
                              + Qdata(:, intStart:intStop).^2, 2))';
            % Phase
            Pdata = unwrap(atan2(mean(Qdata(:, intStart:intStop), 2), ...
                                 mean(Idata(:, intStart:intStop), 2))');

        else
            % Heterodyne
            [Adata, Pdata] ...
                = funclib.Demodulate(1/cardparams.samplerate, ...
                                     Idata(:, intStart:intStop), ...
                                     self.pulseCal.intFreq);
        end
        % Update counts for each sequence
        for seg = 1:numsegs
            [AmpCounts, ~] = histcounts(Adata(seg:numsegs:end), self.result.AmpEdges);
            self.result.AmpCounts(seg, :) = self.result.AmpCounts(seg, :) + AmpCounts;
            [PhaseCounts, ~] = histcounts(Pdata(seg:numsegs:end), self.result.PhaseEdges);
            self.result.PhaseCounts(seg, :) = self.result.PhaseCounts(seg, :) + PhaseCounts;
        end
        % Auto plotting
        if self.doPlot && ~mod(ind, self.updatePlot)
            figure(11);
            subplot(2, 1, 1);
            plot(self.result.AmpEdges(2:end), self.result.AmpCounts);
            title(['SoftAvg ', num2str(ind), ' of ', num2str(self.softwareAverages)]);
            subplot(2, 1, 2);
            plot(self.result.PhaseEdges(2:end), self.result.PhaseCounts);
            drawnow;
        end
    end
    % Plot final results
    self.PlotHistogram();
end