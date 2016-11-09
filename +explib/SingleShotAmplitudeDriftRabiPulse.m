% Sweep delay time from Rabi pulse to measurement
clear sweep
sweep.measDelay = 10.^(linspace(-6,-4,21));
timeString = datestr(datetime);
time=fix(clock);
cardparams.averages=1000;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 
for ind =1:length(sweep.measDelay)
    clear x
    x = explib.SingleShot2DHistogramsRabiPulse(pulseCal,20000,100,1);
    x.measDelay = sweep.measDelay(ind);
    x.update();
    
    tic; playlist = x.directDownloadM8195A(awg); toc
    tic; time=fix(clock);
    result = x.directRunM8195A(awg,card,cardparams,playlist); toc
    [~,indRabi] = max(result.rabiAHist);
    [~,indGnd] = max(result.gndAHist);
    sweep.drift(ind) = result.AEdges(indRabi) - result.AEdges(indGnd);
    
    figure(743)
    plot(sweep.measDelay(1:ind),sweep.drift(1:ind),'or')
    title('Voltage drift vs delay to measurement')
    xlabel('Time (mus)')
    save(['C:\Data\SingleShotDriftRabiPulse'  '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
                    'result','sweep');
end