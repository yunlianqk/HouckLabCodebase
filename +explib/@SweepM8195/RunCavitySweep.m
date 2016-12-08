function RunCavitySweep(self)
    % Run cavity frequency sweep in upconversion OR external LO mode
    % For both cavity and LO in direct synthesis mode,
    % see RunGateSweep() method
    
    global awg card rfgen logen;
    
    numsegs = length(self.cavityFreq);
    cardparams = card.params;
    intStart = self.pulseCal.integrationStartIndex;
    intStop = self.pulseCal.integrationStopIndex;
    
    % Pre-allocate arrays to store results
    self.result.Idata = zeros(numsegs, cardparams.samples);
    self.result.Qdata = zeros(numsegs, cardparams.samples);
    self.result.AmpInt = zeros(1, numsegs);

    % Main loop that sweeps cavity frequency
    segID = 1:cardparams.segments;
    for ind = 1:numsegs
        if self.cavitybaseband
            rfgen.freq = self.cavityFreq(ind);
        end
        if isempty(self.lochannel)
            logen.freq = self.cavityFreq(ind) + self.pulseCal.intFreq;
            pause(0.2);
        end
        % Inner loop for software averaging
        for avg = 1:self.softwareAverages
            % Start AWG and acquire data
            awg.SeqStop(self.playlist(segID));
            card.WaitTrigger();
            awg.SeqRun(self.playlist(segID));
            if self.bgsubtraction
                [tempI, ~, tempQ, ~] = card.ReadIandQcomplicated();
            else
                [tempI, tempQ] = card.ReadIandQ();
            end
            % Update software averaged data
            self.result.Idata(ind, :) = (avg-1)/avg*self.result.Idata(ind, :) + tempI/avg;
            self.result.Qdata(ind, :) = (avg-1)/avg*self.result.Qdata(ind, :) + tempQ/avg;
            % Only amplitude is recorded for now
            if (self.pulseCal.intFreq == 0)
                % Homodyne
                self.result.AmpInt(ind) = sqrt(mean(self.result.Idata(ind, intStart:intStop).^2 ...
                                                    +self.result.Qdata(ind, intStart:intStop).^2, 2))';
            else
                % Heterodyne
                [self.result.AmpInt(ind), ~] ...
                    = funclib.Demodulate(1/cardparams.samplerate, ...
                                         self.result.Idata(ind, intStart:intStop), ...
                                         self.pulseCal.intFreq);
            end
        end
        if ~self.cavitybaseband
            % For direct synthesis BUT external LO, step to next playlist
            segID = segID + cardparams.segments;
        end
        % Auto plotting
        if self.doPlot && ~mod(ind, self.updatePlot)
            figure(10);
            plot(self.cavityFreq(1:ind), self.result.AmpInt(1:ind));
            title(['FreqPts ', num2str(ind), ' of ', num2str(numsegs)]);
        end
    end
    % Plot final results
    self.PlotCavitySweep();
end