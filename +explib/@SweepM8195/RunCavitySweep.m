function RunCavitySweep(self)

    global awg card rfgen logen;
        
    numsegs = length(self.cavityFreq);
    cardparams = card.params;
    self.result.Idata = zeros(numsegs, cardparams.samples);
    self.result.Qdata = zeros(numsegs, cardparams.samples);
    self.result.AmpInt = zeros(1, numsegs);
    intStart = self.pulseCal.integrationStartIndex;
    intStop = self.pulseCal.integrationStopIndex;
    
    for ind = 1:numsegs
        rfgen.freq = self.cavityFreq(ind);
        logen.freq = self.cavityFreq(ind) + self.pulseCal.intFreq;
        pause(0.2);
        for avg = 1:self.softwareAverages
            awg.SeqStop(self.playlist);
            card.WaitTrigger();
            awg.SeqRun(self.playlist);
            if self.bgsubtraction
                [tempI, ~, tempQ, ~] = card.ReadIandQcomplicated();
            else
                [tempI, tempQ] = card.ReadIandQ();
            end
            self.result.Idata(ind, :) = (avg-1)/avg*self.result.Idata(ind, :) + tempI/avg;
            self.result.Qdata(ind, :) = (avg-1)/avg*self.result.Qdata(ind, :) + tempQ/avg;
            if (self.pulseCal.intFreq == 0)
                self.result.AmpInt(ind) = sqrt(mean(self.result.Idata(ind, intStart:intStop).^2 ...
                                                    +self.result.Qdata(ind, intStart:intStop).^2, 2))';
            else
                [self.result.AmpInt(ind), ~] ...
                    = funclib.Demodulate(1/cardparams.samplerate, ...
                                         self.result.Idata(ind, intStart:intStop), ...
                                         self.pulseCal.intFreq);
            end
        end
        
        if self.doPlot && ~mod(ind, self.updatePlot)
            figure(10);
            plot(self.cavityFreq(1:ind), self.result.AmpInt(1:ind));
            title(['FreqPts ', num2str(ind), ' of ', num2str(numsegs)]);
        end
    end
    self.PlotCavitySweep();
end