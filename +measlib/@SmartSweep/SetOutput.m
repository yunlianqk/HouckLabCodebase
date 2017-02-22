function SetOutput(self)

    global pulsegen1 pulsegen2 rfgen specgen specgen2 card fluxgen;

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
    self.result.tAxis = cardparams.delaytime + ...
                        cardparams.sampleinterval*(0:cardparams.samples-1);
    self.result.sampleinterval = cardparams.sampleinterval;
    self.result.intRange = [];
    self.result.intFreq = self.intfreq;
    self.result.dataI = zeros(self.numSweep2, cardparams.samples);
    self.result.dataQ = zeros(self.numSweep2, cardparams.samples);
    
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
    function PlotSweep2(dataI, dataQ)
        figure(100);
        subplot(2, 2, 1);
        plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform1, ...
             pulsegen1.timeaxis/1e-6, pulsegen1.waveform2, 'r');
        axis tight;
        ylim([-1, 1]);
        legend('ch1', 'ch2');
        title('AWG 1');
        subplot(2, 2, 3);
        plot(pulsegen2.timeaxis/1e-6, pulsegen2.waveform1, ...
             pulsegen2.timeaxis/1e-6, pulsegen2.waveform2, 'r');
        axis tight;
        ylim([-1, 1]);
        title('AWG 2');
        xlabel('Time (\mus)');
        subplot(2, 2, 2);
        imagesc(self.result.tAxis/1e-6, 1:size(dataI, 1), dataI);
        title('I data');
        subplot(2, 2, 4);
        imagesc(self.result.tAxis/1e-6, 1:size(dataQ, 1), dataQ);
        title('Q data');
        xlabel('Time (\mus)');
    end
    function PlotSweep1(amp, phase)
        figure(101);
        subplot(2, 1, 1);
        if size(amp, 1) == 1 || size(amp, 2) == 1
            plot(amp);
        else
            imagesc(amp);
        end
        title('Amplitude');
        subplot(2, 1, 2);
        if size(phase, 1) == 1 || size(phase, 2) == 1
            plot(phase);
        else
            imagesc(phase);
        end
        title('Phase');
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
        try
            specgen2.PowerOff();
        catch
        end
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        specgen.PowerOn();
        try
            specgen2.PowerOn();
        catch
        end
    end
    function [Ibg, Qbg] = FluxOnOff()
        fluxgen.PowerOff();
        pause(self.waittime);
        [Ibg, Qbg] = card.ReadIandQ();
        fluxgen.PowerOn();
    end
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