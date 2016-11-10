%  Hahn Echo experiment while sweeping qubit frequency

echoOrder = 5;
delayList = logspace(-5.8,-3.6,50); % total delay from 1st to last pulse
softwareAverages = 20; 
qFstart=4.774e9;
qFstop=4.794e9;
points = 41;
qubitFreqvect = linspace(qFstart,qFstop,points);

sweepResult.Pint = zeros(points,length(delayList));
sweepResult.AmpNorm = zeros(points,length(delayList));
% sweepResult.T2echo = zeros(points,1);
pulseCal_temp = pulseCal;

for ind =1:points
    display([' ']);
    display(['Hahn Echo with ' num2str(echoOrder) ' pi pulses for qubit freq ' num2str(qubitFreqvect(ind)/1e9) 'GHz'])
    clear x
    pulseCal_temp.qubitFreq = qubitFreqvect(ind); 
    x = explib.HahnEchoNthOrder(pulseCal_temp, echoOrder, delayList, softwareAverages);
    playlist = x.directDownloadM8195A(awg);
    time=fix(clock);
    timeString = datestr(datetime);
    tic;
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    toc
    
    sweepResult.Pint(ind,:) = result.Pint(1:50);
    sweepResult.AmpNorm(ind,:) = result.AmpNorm;
%     sweepResult.T2echo(ind,:) = result.fitResults.lambda;
    
    figure(222)
%     subplot(1,2,1)
    imagesc(log10(delayList),qubitFreqvect(1:ind)./1e9,sweepResult.Pint(1:ind,:))
    title(['Hahn Echo with ' num2str(echoOrder) ' pi pulses vs Qubit frequency'])
    xlabel('Echo signal');ylabel('Qubit freq (GHz)');
%     subplot(1,2,2)
%     plot(qubitFreqvect(1:ind)./1e9,sweepResult.T2echo(1:ind,:)./1e-6,'--ok')
%     xlabel('Qubit freq (GHz)');ylabel('T2 echo(us)');
    drawnow
end

save(['C:\Data\HahnEchosweepQubitFreq' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'sweepResult', 'awg','card','cardparams');
%%
sweepResult.T2echo = zeros(points,1);
xaxisNorm = result.xaxisNorm;
for ind =1:points
   fitResults = funclib.ExpFit3(xaxisNorm,sweepResult.AmpNorm(ind,:)); 
   sweepResult.T2echo(ind,:) = fitResults.lambda;
end

figure();
plot(qubitFreqvect,sweepResult.T2echo','--or')
    
