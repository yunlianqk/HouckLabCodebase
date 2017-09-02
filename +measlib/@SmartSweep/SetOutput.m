function SetOutput(self)

    global pulsegen1 pulsegen2 pulsegen3 logen logen2 card fluxgen;

    % Set up signal and background acquisition function handles
    if self.histogram
        self.acqsigfunc = @AcqHist;
    else
        self.acqsigfunc = @AcqData;
    end

    if isempty(self.bgsubtraction)
        self.acqbgfunc = @ZeroBackground;
    else
        switch self.bgsubtraction
            case 'speconoff'
                self.acqbgfunc = @SpecOnOff;
            case 'rfonoff'
                self.acqbgfunc = @RFOnOff;
            case 'fluxonoff'
                self.acqbgfunc = @FluxOnOff;
            otherwise
                error('Unknown background subtraction type.');
        end
    end

    % Set up parameters in self.result
    cardparams = card.GetParams();
    % Time axis and sample interval are read from card
    self.result.tAxis = cardparams.delaytime + ...
                        cardparams.sampleinterval*(0:cardparams.samples-1);
    self.result.sampleinterval = cardparams.sampleinterval;
    % Integration range is read from self.intrange
    self.result.intRange = self.intrange;
    % Channel setting is read from self.cardchannel
    self.result.cardchannel = self.cardchannel;
    % Normalization is read from self.normalization
    self.result.normalization = self.normalization;
    % Histogram is read from self.histogram
    self.result.histogram = self.histogram;
    % Intermediate frequency is read from self.intfreq or self.int2freq
    if ~isempty(self.generator{5})
        switch self.generator{5}
            case logen
                self.result.intFreq = self.intfreq;
            case logen2
                self.result.intFreq = self.int2freq;
            otherwise
        end
    end
    if ~isempty(self.generator{7})
        switch self.generator{7}
            case logen
                self.result.intFreq = self.intfreq;
            case logen2
                self.result.intFreq = self.int2freq;
            otherwise
        end
    end
    % Pre-allocate dataI and dataQ
    self.result.dataI = zeros(self.numSweep2, cardparams.samples);
    self.result.dataQ = zeros(self.numSweep2, cardparams.samples);
    if isempty(self.result.rowAxis)
        self.result.rowAxis = 1:self.numSweep2;
    end
    % Pre-allocate intI and intQ
    if self.histogram
        self.result.intI = zeros(self.numSweep2, cardparams.segments*self.histrepeat);
        self.result.intQ = zeros(self.numSweep2, cardparams.segments*self.histrepeat);
    else
        self.result.intI = zeros(self.numSweep1, self.numSweep2);
        self.result.intQ = zeros(self.numSweep1, self.numSweep2);
    end
    % Set up plot function handles
    if self.plotsweep1
        self.plot1func = @PlotSweep1;
    else
        self.plot1func = @DoNothing;
    end
    if self.plotsweep2
        self.plot2func = @PlotSweep2;
    else
        self.plot2func = @DoNothing;
    end    
    % Estimate total measurement time
    totaltime = (cardparams.trigPeriod*cardparams.averages ...
                 *cardparams.segments*self.histrepeat + self.waittime) ...
                *self.numSweep1*self.numSweep2;
    if ~isempty(self.bgsubtraction)
        totaltime = totaltime*2;
    end
    display(['Estimated measurement time: ', num2str(totaltime), ' seconds.']);
    
%=================functions whose handles are used above===================
    % Plot function
    function PlotSweep2(ind)
        figure(100);
        subplot(2, 2, 1);
        plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform1, ...
             pulsegen1.timeaxis/1e-6, pulsegen1.waveform2, 'r', ...
             pulsegen1.timeaxis/1e-6, pulsegen1.marker3, 'k');
        axis tight;
        ylim([-1, 1]);
        legend('ch1', 'ch2', 'mkr3');
        title('AWG 1');
        subplot(2, 2, 3);
%         plot(pulsegen2.timeaxis/1e-6, pulsegen2.waveform1, ...
%              pulsegen2.timeaxis/1e-6, pulsegen2.waveform2, 'r', ...
%              pulsegen2.timeaxis/1e-6, pulsegen2.marker3, 'k');
        axis tight;
        ylim([-1, 1]);
        title('AWG 2');
        xlabel('Time (\mus)');
        subplot(2, 2, 2);
        imagesc(self.result.tAxis/1e-6, 1:ind, self.result.dataI(1:ind, :));
        title('I data');
        subplot(2, 2, 4);
        imagesc(self.result.tAxis/1e-6, 1:ind, self.result.dataQ(1:ind, :));
        title('Q data');
        xlabel('Time (\mus)');
        if strcmp(self.name, 'FluxDCoffset')
            figure(201);
            plot(pulsegen3.timeaxis/1e-6, pulsegen3.waveform1, ...
                 pulsegen3.timeaxis/1e-6, pulsegen3.waveform2, 'r', ...
                 pulsegen3.timeaxis/1e-6, pulsegen3.marker3, 'k');
            axis tight;
            ylim([-1, 1]);
            title('AWG 3');
            xlabel('Time (\mus)');
        end
        drawnow;
    end
    function PlotSweep1(ind)
        figure(101);
        subplot(2, 1, 1);
        imagesc(self.result.intI(1:ind, :));
        title('Integrated I');
        subplot(2, 1, 2);
        imagesc(self.result.intQ(1:ind, :));
        title('Integrated Q');
        drawnow;
    end
    % Acquisition function
    function AcqData(ind)
        [self.result.dataI(ind, :), self.result.dataQ(ind, :)] = card.ReadIandQ();
    end
    function AcqHist(ind)
        for seg = 1:self.histrepeat
            [self.result.dataI, self.result.dataQ] = card.ReadIandQ();
            [self.result.intI(ind, (seg-1)*cardparams.segments+1:seg*cardparams.segments), ...
             self.result.intQ(ind, (seg-1)*cardparams.segments+1:seg*cardparams.segments)] ...
                = self.Integrate();
        end
    end
    function DoNothing(varargin)
    end    
    % Background substraction function
    function [Ibg, Qbg] = ZeroBackground()
        Ibg = 0;
        Qbg = 0;
    end
    function [Ibg, Qbg] = SpecOnOff()
        self.generator{1}.PowerOff();
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        self.generator{1}.PowerOn();
    end
    function [Ibg, Qbg] = FluxOnOff()
        fluxgen.PowerOff();
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        fluxgen.PowerOn();
    end
    function [Ibg, Qbg] = RFOnOff()
        self.generator{4}.PowerOff();
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        self.generator{4}.PowerOn();
    end
end