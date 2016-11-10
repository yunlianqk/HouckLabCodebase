% T2 Chevron Experiment
% when your ramsey fit sux, what chu gon do? this.

detuningVector = linspace(-10e6,10e6,101);
cardparams.averages=20;  % software averages PER SEGMENT
delayList = 200e-9:.005e-6:1.2e-6; % delay btw qubit pulses
softwareAverages = 10;
clear sweep
clear x

card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring

for ind = 1:length(detuningVector)
    clear x
    detuning = detuningVector(ind);
    x = explib.T2Experiment_v2(pulseCal,delayList,detuning,softwareAverages);
    tic; playlist = x.directDownloadM8195A(awg); toc
    % Run an experiment
    tic; time=fix(clock);
    result = x.directRunM8195A(awg,card,cardparams,playlist); toc
    sweep.ampNorm(ind,:) = result.AmpNorm;
    
    figure(555)
    imagesc(result.xaxisNorm,detuningVector(1:ind),sweep.ampNorm(1:ind,:))
    title('T2 Chevy Nova')
    ylabel('detuning');xlabel('time')
    drawnow
    
end
   
save(['C:\Data\T2Chevron' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result','sweep');
beep
