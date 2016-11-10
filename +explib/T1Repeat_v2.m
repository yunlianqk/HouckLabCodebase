%  T1 Repeat V2
% this script repeats a single experiment multiple times.  since loading
% the waveforms is done only once many iterations can be done relatively quickly.

% delayList = .2e-6:1.50e-6:150.2e-6; % total delay from 1st to last pulse
delayList = 1e-9*logspace(2,5.4,50); % total delay from 1st to last pulse
softwareAverages = 20;
pauseTime = 20;
cardparams.averages=25;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 
prealloc = 1000; % estimated number of T1 measurements to record (it's not the end of the world if you go over)

%initializions
display([' ']);
display(['T1 Repeat'])
clear x
x = explib.T1Experiment_v2(pulseCal,delayList,softwareAverages);
playlist = x.directDownloadM8195A(awg);

%%
time=fix(clock);
timeString = datestr(datetime);
%preallocation
loopResults.experiment = x;
loopResults.pulseCal = x.pulseCal;
loopResults.amp = zeros(1,prealloc);
loopResults.T1 = zeros(1,prealloc);
loopResults.offset = zeros(1,prealloc);
% loopResults.R = zeros(1,prealloc);

testNum = 0;
while 1
    
    pause(pauseTime)
    testNum = testNum+1;
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    
    loopResults.T1(testNum) = result.fitResults.lambda;
    loopResults.offset(testNum) = result.fitResults.offset;
    loopResults.amp(testNum) = result.fitResults.amp;
    
    figure(612)
    subplot(1,2,1)
    plot(abs(loopResults.T1(1:testNum)),'--or')
    title(['T1Repeat_v2 ' x.experimentName ' ' timeString]);
    xlabel('Delay')
    ylabel('T1')
    subplot(1,2,2)
    histogram(abs(loopResults.T1(1:testNum))/1e-6);
    drawnow
    
    save(['C:\Data\T1Loop' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'loopResults', 'awg','card','cardparams');
    
end
