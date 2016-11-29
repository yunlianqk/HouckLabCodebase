function RunGateSweep(self)

    global awg card;
    
    cardparams = card.GetParams();
    if self.bgsubtraction
        numsegs = cardparams.segments/2;
    else
        numsegs = cardparams.segments;
    end
    self.result.Idata = zeros(numsegs, cardparams.samples);
    self.result.Qdata = zeros(numsegs, cardparams.samples);
    intStart = self.pulseCal.integrationStartIndex;
    intStop = self.pulseCal.integrationStopIndex;
    
    for ind = 1:self.softwareAverages
        awg.SeqStop(self.playlist);
        card.WaitTrigger();
        awg.SeqRun(self.playlist);
        if self.bgsubtraction
            [tempI, ~, tempQ, ~] = card.ReadIandQcomplicated();
        else
            [tempI, tempQ] = card.ReadIandQ();
        end
        self.result.Idata = (ind-1)/ind*self.result.Idata + tempI/ind;
        self.result.Qdata = (ind-1)/ind*self.result.Qdata + tempQ/ind;
        if (self.pulseCal.intFreq == 0)
            meanI = mean(self.result.Idata(:, intStart:intStop), 2)';
            meanQ = mean(self.result.Qdata(:, intStart:intStop), 2)';
            self.result.AmpInt = sqrt(meanI.^2 +meanQ.^2);
            self.result.PhaseInt = atan2(meanQ, meanI);
        else
            [self.result.AmpInt, self.result.PhaseInt] ...
                = funclib.Demodulate(1/cardparams.samplerate, ...
                                     self.result.Idata(:, intStart:intStop), ...
                                     self.pulseCal.intFreq);
        end
        
        if self.doPlot && ~mod(ind, self.updatePlot)
            figure(10);
            plot(1:numsegs, self.result.AmpInt);
            title(['SoftAvg ', num2str(ind), ' of ', num2str(self.softwareAverages)]);
            drawnow;
        end
    end
    
    if self.normalization
        self.result.AmpInt = (self.result.AmpInt(1:end-2)-self.result.AmpInt(end-1)) ...
                             /(self.result.AmpInt(end)-self.result.AmpInt(end-1));
        self.result.PhaseInt = (self.result.PhaseInt(1:end-2)-self.result.PhaseInt(end-1)) ...
                               /(self.result.PhaseInt(end)-self.result.PhaseInt(end-1));
    end
    % Plot final result
    figure(10);
    plot(self.result.AmpInt);
    xlabel('Sequence');
    ylabel('Amplitude');
    title(self.experimentName);
end