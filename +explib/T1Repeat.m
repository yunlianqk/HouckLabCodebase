%  T1 Repeat
% this script repeats a single experiment multiple times.  since loading
% the waveforms is done only once many iterations can be done relatively quickly.

delayList = .2e-6:1.50e-6:150.2e-6; % total delay from 1st to last pulse

%initializions
display([' ']);
display(['T1 Repeat'])
clear x
x = explib.T1Experiment(pulseCal);
playlist = x.directDownloadM8195A(awg);
cardparams.averages=25;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 
%%
time=fix(clock);
timeString = datestr(datetime);
testNum = 0;
while 1
    tic;
    testNum = testNum+1;
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    
    loopResults.taxis = result.taxis;
    loopResults.pulseCal = x.pulseCal;
    loopResults.experiment = x;
    loopResults.Pint = result.Pint;
    loopResults.T1(testNum) = result.lambda;
%     loopResults.AmpNorm(testNum,:) = result.AmpNorm;
%     loopResults.T2Echo(testNum) = result.fitResults.lambda;
    
    
    figure(612)
    plot(abs(loopResults.T1(1:testNum)))
    title(['looping ' x.experimentName ' ' timeString]);
    xlabel('Delay')
    ylabel('T1')
    drawnow
    
    save(['C:\Data\T1Loop' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'loopResults', 'awg','card','cardparams');
    toc
end
