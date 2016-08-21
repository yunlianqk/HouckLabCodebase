%  T1 Repeat
% this script repeats a single experiment multiple times.  since loading
% the waveforms is done only once many iterations can be done relatively quickly.

echoOrder = 1;
delayList = .2e-6:1.00e-6:100.2e-6; % total delay from 1st to last pulse


%initializions
display([' ']);
display(['T1 Repeat'])
clear x
x = explib.T1Experiment(pulseCal);
playlist = x.directDownloadM8195A(awg);
%%
time=fix(clock);
timeString = datestr(datetime);
tic;
testNum = 0;
while 1
    testNum = testNum+1;
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    
    loopResults.taxis = result.taxis
    loopResults.pulseCal = x.pulseCal;
    loopResults.experiment = x;
    loopResults.AmpNorm(testNum,:) = result.AmpNorm;
    loopResults.T2Echo(testNum) = result.fitResults.lambda;
    
    
    figure(612)
    plot(loopResults.T2Echo(1:testNum))
    title(['looping ' x.experimentName ' ' timeString '; ' num2str(echoOrder) ' Pi pulses']);
    xlabel('Number of Pi pulses')
    ylabel('T2 Echo')
    drawnow
    
    save(['C:\Data\HahnEchoSingleOrderRepeat' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'loopResults', 'awg','card','cardparams');
    toc
end
