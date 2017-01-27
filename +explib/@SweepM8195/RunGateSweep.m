function RunGateSweep(self)
    % Send qubit gate sequences and acquire data
    
    global awg card;
    
    cardparams = card.GetParams();
    intStart = self.pulseCal.integrationStartIndex;
    intStop = self.pulseCal.integrationStopIndex;
    if self.bgsubtraction
        numsegs = cardparams.segments/2;
    else
        numsegs = cardparams.segments;
    end

    % Pre-allocate arrays to store results
    self.result.Idata = zeros(numsegs, cardparams.samples);
    self.result.Qdata = zeros(numsegs, cardparams.samples);
    
    % Main (software averaging) loop that update I/Q and Amp/Phase data
    for ind = 1:self.softwareAverages
        % Start AWG and acquire data
        awg.SeqStop(self.playlist);
        card.WaitTrigger();
        awg.SeqRun(self.playlist);
        if self.bgsubtraction
            [tempI, ~, tempQ, ~] = card.ReadIandQcomplicated();
        else
            [tempI, tempQ] = card.ReadIandQ();
        end
        % Update software averaged data
        self.result.Idata = (ind-1)/ind*self.result.Idata + tempI/ind;
        self.result.Qdata = (ind-1)/ind*self.result.Qdata + tempQ/ind;
        if (self.pulseCal.intFreq == 0)
            % Homodyne
            meanI = mean(self.result.Idata(:, intStart:intStop), 2)';
            meanQ = mean(self.result.Qdata(:, intStart:intStop), 2)';
            % Amplitude
            self.result.AmpInt = sqrt(meanI.^2 +meanQ.^2);
            % Phase
            self.result.PhaseInt = atan2(meanQ, meanI);
        else
            % Heterodyne
            [self.result.AmpInt, self.result.PhaseInt] ...
                = funclib.Demodulate(1/cardparams.samplerate, ...
                                     self.result.Idata(:, intStart:intStop), ...
                                     self.pulseCal.intFreq);
        end
        % Auto plotting
        if self.doPlot && ~mod(ind, self.updatePlot)
            figure(10);
            plot(1:numsegs, self.result.AmpInt);
            title(['SoftAvg ', num2str(ind), ' of ', num2str(self.softwareAverages)]);
            drawnow;
        end
    end
    
    if self.normalization
        % If last two sequences are normalization
        % Record amp/phase for ground/excited state 
        self.result.AmpGnd = self.result.AmpInt(end-1);
        self.result.AmpEx = self.result.AmpInt(end);
        self.result.PhaseGnd = self.result.PhaseInt(end-1);
        self.result.PhaseEx = self.result.PhaseInt(end);
        % Normalize amp/phase
        self.result.AmpInt = (self.result.AmpInt(1:end-2)-self.result.AmpGnd) ...
                             /(self.result.AmpEx-self.result.AmpGnd);
        self.result.PhaseInt = (self.result.PhaseInt(1:end-2)-self.result.PhaseGnd) ...
                               /(self.result.PhaseEx-self.result.PhaseGnd);
    end
    % Plot final results
    self.PlotGateSweep();
end