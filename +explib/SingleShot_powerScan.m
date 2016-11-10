% SingleShot_powerScan
% finds single shot readout fidelity as a function of measurement pulse
% power.

% amplitudeVector = linspace(.52,.58,20);
amplitudeVector = linspace(.5,1,20);

% Parameters for singleshotre
trials = 25000;
bins = 100;
doPlot = 0;
cardparams.averages=1000;  % software averages PER SEGMENT
cardparams.samples=round(1.6e9*1.25e-6);    % samples for a single trace
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 

display([' ']);
display(['SingleShot_powerScan'])

%%
time=fix(clock);
timeString = datestr(datetime);
clear x

loopResults.optimalFidelity = zeros(1,length(amplitudeVector));
loopResults.optimalWindow = zeros(1,length(amplitudeVector));
loopResults.optimalThreshold = zeros(1,length(amplitudeVector));
loopResults.fidelity = zeros(cardparams.samples,length(amplitudeVector));
loopResults.threshInd = zeros(cardparams.samples,length(amplitudeVector));
loopResults.gndOptHist = zeros(bins,length(amplitudeVector));
loopResults.exOptHist = zeros(bins,length(amplitudeVector));
loopResults.gndOptCDF = zeros(bins,length(amplitudeVector));
loopResults.exOptCDF = zeros(bins,length(amplitudeVector));
loopResults.edges = zeros(bins+1,length(amplitudeVector));

for ind = 1:length(amplitudeVector)
    tic;
    x = explib.SingleShotReadoutFidelity_v2(pulseCal,trials,bins,doPlot);
    x.pulseCal.cavityAmplitude = amplitudeVector(ind);
    x.update();
    playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    
    loopResults.optimalFidelity(ind) = result.optimalFidelity;
    loopResults.optimalWindow(ind) = result.optimalWindow;
    loopResults.optimalThreshold(ind) = result.optimalThreshold;
    loopResults.fidelity(:,ind) = result.fidelity';
    loopResults.threshInd(:,ind) = result.threshInd';
    loopResults.gndOptHist(:,ind) = result.gndOptHist;
    loopResults.exOptHist(:,ind) = result.exOptHist;
    loopResults.gndOptCDF(:,ind) = result.gndOptCDF;
    loopResults.exOptCDF(:,ind) = result.exOptCDF;
    loopResults.edges(:,ind) = result.edges';
    
    figure(213);
    subplot(1,2,1)
    [hAx,hLine1,hLine2]=plotyy(amplitudeVector(1:ind), loopResults.optimalFidelity(1:ind),amplitudeVector(1:ind), loopResults.optimalWindow(1:ind))
%     plot(amplitudeVector(1:ind), loopResults.optimalFidelity(1:ind))
    title(['looping ' x.experimentName ' ' timeString]);
    xlabel('amplitude')
    ylabel(hAx(1),'optimal fidelity')
    ylabel(hAx(2),'optimal window')
    subplot(1,2,2)
    imagesc(loopResults.fidelity(:,1:ind))
    drawnow
    toc
end


save(['C:\Data\SingleShot_powerScan' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'loopResults', 'awg','card','cardparams','x','amplitudeVector','trials','bins');
