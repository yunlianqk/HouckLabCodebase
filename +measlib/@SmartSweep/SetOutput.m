function SetOutput(self)

    global pulsegen1 pulsegen2 specgen card fluxgen;

    % Set up signal and background acquisition function handles
    self.acqsigfunc = @card.ReadIandQ;
    if isempty(self.bgsubtraction)
        self.acqbgfunc = @ZeroBackground;
    else
        switch self.bgsubtraction
            case 'speconoff'
                self.acqbgfunc = @SpecOnOff;
            case 'rfonoff'
                self.acqbgfunc = @RFOnOff;
            case 'pulseonoff'
                self.acqbgfunc = @PulseOnOff;
            case 'fluxonoff'
                self.acqbgfunc = @FluxOnOff;
            otherwise
                error('Unknown background subtraction type.');
        end
    end
    
    % Pre-allocate output data
    cardparams = card.GetParams();
    self.IQdata.colAxis = cardparams.delaytime + ...
                          cardparams.sampleinterval*(0:cardparams.samples-1);
    self.IQdata.sampleinterval = cardparams.sampleinterval;
    self.IQdata.intFreq = self.intfreq;
    self.IQdata.rawdataI = zeros(self.numSweep2, cardparams.samples);
    self.IQdata.rawdataQ = zeros(self.numSweep2, cardparams.samples);
    self.ampI = zeros(self.numSweep1, self.numSweep2);
    self.phaseI = zeros(self.numSweep1, self.numSweep2);
    self.ampQ = zeros(self.numSweep1, self.numSweep2);
    self.phaseQ = zeros(self.numSweep1, self.numSweep2);
    self.IQdata.intRange = self.intrange;
    
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
    totaltime = (cardparams.trigPeriod*cardparams.averages+self.waittime) ...
                 *self.numSweep1*self.numSweep2;
    if ~isempty(self.bgsubtraction)
        totaltime = totaltime*2;
    end
    display(['Estimated measurement time: ', num2str(totaltime), ' seconds.']);
    
%=================functions whose handles are used above===================
    function PlotSweep2(Idata, Qdata)
        figure(101);
        subplot(2, 2, 1);
        plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform1, ...
             pulsegen1.timeaxis/1e-6, pulsegen1.waveform2, 'r');
        axis tight;
        ylim([-1, 1]);
        legend('I', 'Q');
        title('AWG 1');
        subplot(2, 2, 3);
        plot(pulsegen2.timeaxis/1e-6, pulsegen2.waveform1, ...
             pulsegen2.timeaxis/1e-6, pulsegen2.waveform2, 'r');
        axis tight;
        ylim([-1, 1]);
        title('AWG 2');
        xlabel('Time (\mus)');
        subplot(2, 2, 2);
        imagesc(self.IQdata.colAxis/1e-6, 1:size(Idata, 1), Idata);
        title('I data');
        subplot(2, 2, 4);
        imagesc(self.IQdata.colAxis/1e-6, 1:size(Qdata, 1), Qdata);
        title('Q data');
        xlabel('Time (\mus)');
    end
    function PlotSweep1(Iamp, Iphase, Qamp, Qphase)
        figure(102);
        subplot(2, 2, 1);
        if size(Iamp, 1) == 1 || size(Iamp, 2) == 1
            plot(Iamp);
        else
            imagesc(Iamp);
        end
        title('I amplitude');
        subplot(2, 2, 3);
        if size(Iphase, 1) == 1 || size(Iphase, 2) == 1
            plot(Iphase);
        else
            imagesc(Iphase);
        end
        title('I phase');
        subplot(2, 2, 2);
        if size(Qamp, 1) == 1 || size(Qamp, 2) == 1
            plot(Qamp);
        else
            imagesc(Qamp);
        end
        title('Q amplitude');
        subplot(2, 2, 4);
        if size(Qphase, 1) == 1 || size(Qphase, 2) == 1
            plot(Qphase);
        else
            imagesc(Qphase);
        end
        title('Q phase');
    end
    function DoNothing(varargin)
    end    
    % Set background substraction function
    function [Ibg, Qbg] = ZeroBackground()
        Ibg = 0;
        Qbg = 0;
    end
    function [Ibg, Qbg] = SpecOnOff()
        specgen.PowerOff();
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        specgen.PowerOn();
    end
    function [Ibg, Qbg] = FluxOnOff()
        fluxgen.PowerOff();
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        fluxgen.PowerOn();
    function [Ibg, Qbg] = RFOnOff()
        rfgen.PowerOff();
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        rfgen.PowerOn();
    end
    function [Ibg, Qbg] = PulseOnOff()
        ch1 = pulsegen1.waveform1;
        ch2 = pulsegen1.waveform2;
        ch4 = pulsegen2.waveform2;
        pulsegen1.waveform1 = zeros(1, length(ch1));
        pulsegen1.waveform2 = zeros(1, length(ch2));
        pulsegen2.waveform2 = zeros(1, length(ch4));
        pulsegen1.Generate();
        pulsegen2.Generate();
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        pulsegen1.waveform1 = ch1;
        pulsegen1.waveform2 = ch2;
        pulsegen2.waveform2 = ch4;
        pulsegen1.Generate();
        pulsegen2.Generate();
    end    
end