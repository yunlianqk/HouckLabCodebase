%  Hahn Echo Single Order Repeat
% this script repeats a single experiment multiple times.  since loading
% the waveforms is done only once many iterations can be done.

echoOrder = 1;
delayList = logspace(-5.8,-3.6,50); % total delay from 1st to last pulse
softwareAverages = 5; 

%initializions
display([' ']);
display(['Hahn Echo with ' num2str(echoOrder) ' pi pulses'])
clear x
x = explib.HahnEchoNthOrder(pulseCal, echoOrder, delayList, softwareAverages);
playlist = x.directDownloadM8195A(awg);
%%
time=fix(clock);
timeString = datestr(datetime);
tic;
testNum = 0;
while 1
    testNum = testNum+1;
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    
    loopResults.xaxisNorm = result.xaxisNorm;
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
