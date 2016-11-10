%% Test the weird long time drift behavior.

% 1 = I
% 2 = X180
% 3 = X90
% 4 = Xm90
% 5 = Y180
% 6 = Y90
% 7 = Ym90

% vector of how many x90 pulses should be done between the 'normalization'
% segments
% repeatsVector=0:10:800;   
% repeatsVector=0:20:1600;   
repeatsVector=0:2:80;   
softwareAverages = 300;

% studying long time strange behavior
initGate = 2; % initialize onto equator
repeatedGates = [2];


gateLists = cell(1,2*length(repeatsVector)+1);
gateLists(1) = {[1]};
for ind=1:length(repeatsVector)
    ind2 = ind*2;
    numRepeats = repeatsVector(ind);
    tempGateList = [ initGate repmat(repeatedGates, 1, numRepeats)];
    gateLists(ind2) = {tempGateList};
%     add normalization pulses inbetween
    if mod(ind,2)
        gateLists(ind2+1) = {[2]};
    else
        gateLists(ind2+1) = {[1]};
    end
end

x = explib.ArbSequence(pulseCal,gateLists,softwareAverages);

cardparams.averages=10;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 
tic; playlist = x.directDownloadM8195A(awg); toc
% Run an experiment
tic; time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist); toc
result.repeatsVector = repeatsVector;
result.initGate = initGate;
result.repeatedGates = repeatedGates;
save(['C:\Data\ArbErrorAmp' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
beep

%% sweep y azimuth
% sweepDetuning = linspace(80*pi/180,100*pi/180,11);
sweepDetuning = linspace(87*pi/180,91*pi/180,41);
initialPulseCal = pulseCal;
clear sweep
sweep.sweepVector = sweepDetuning;
sweep.ampNorm = zeros(length(sweepDetuning),length(x.gateLists));
cardparams.averages=20;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring

for ind = 1:length(sweepDetuning)
   clear x;
   x = explib.ArbSequence(pulseCal,gateLists,softwareAverages);
   
   %change a parameter
%    x.pulseCal.qubitFreq = initialPulseCal.qubitFreq+sweepVector(ind);
   x.pulseCal.YAzimuth = sweepDetuning(ind);
   x.update();
   
   tic; playlist = x.directDownloadM8195A(awg); toc
   tic; time=fix(clock);
   result = x.directRunM8195A(awg,card,cardparams,playlist); toc
   sweep.ampNorm(ind,:) = result.AmpNorm;
   
   figure(555)
%    plot(result.xaxisNorm,sweep.ampNorm(ind,:),'-o')
      imagesc(result.xaxisNorm,(sweep.sweepVector(1:ind).*180./pi-90),sweep.ampNorm(1:ind,:))
%    set(gca,'xtick',(1:length(x.seqNames)));
%    set(gca,'xticklabel',x.seqNames);
%    ax = gca;
%    ax.XTickLabelRotation=45;
%    plotlib.hline(1);
%    plotlib.hline(.5);
%    plotlib.hline(0);
   title('Sweeping ArbErrorAmp')
   ylabel('YAzimuth Offset');xlabel('numRepeats')
   drawnow
end
save(['C:\Data\ArbErrorAmp' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'sweep','result');
%% sweep qubit freq
sweepDetuning = linspace(-2e6,2e6,41);
initialPulseCal = pulseCal;
clear sweep

time=fix(clock);
softwareAverages = 10;
sweep.sweepVector = sweepDetuning;
sweep.ampNorm = zeros(length(sweepDetuning),length(x.gateLists));
cardparams.averages=20;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring

for ind = 1:length(sweepDetuning)
   clear x;
   x = explib.ArbSequence(pulseCal,gateLists,softwareAverages);
    % this doesn't work because the pulse objects are only baseband...
    %    zeroGate = x.zeroGate;
    %    oneGate = x.oneGate;
   
   %change a parameter
   
   x.pulseCal.qubitFreq
   x.pulseCal.qubitFreq = initialPulseCal.qubitFreq+sweep.sweepVector(ind);
   x.update();
   x.pulseCal.qubitFreq
   
    %    x.zeroGate = zeroGate;
    %    x.oneGate = oneGate;
   
   tic; playlist = x.directDownloadM8195A(awg); toc
   tic; time=fix(clock);
   result = x.directRunM8195A(awg,card,cardparams,playlist); toc
   sweep.ampNorm(ind,:) = result.AmpNorm;
   
   figure(555)
%    plot(result.xaxisNorm,sweep.ampNorm(ind,:),'-o')
    imagesc(result.xaxisNorm,(sweep.sweepVector(1:ind)./1e6),sweep.ampNorm(1:ind,:))
%    set(gca,'xtick',(1:length(x.seqNames)));
%    set(gca,'xticklabel',x.seqNames);
%    ax = gca;
%    ax.XTickLabelRotation=45;
%    plotlib.hline(1);
%    plotlib.hline(.5);
%    plotlib.hline(0);
    title('Sweeping ArbErrorAmp')
    ylabel('Qubit freq detuning (MHz)');xlabel('numRepeats')
    drawnow

end

save(['C:\Data\SweepArbXYErrorAmp' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
           'cardparams','pulseCal','x', 'sweep','result');


%% sweep Y90 azimuth
% Repeated gate sequence should be [3 3 6] = X90X90Y90
% sweepDetuning = linspace(80*pi/180,100*pi/180,11);
sweepDetuning = linspace(89*pi/180,91*pi/180,41);
initialPulseCal = pulseCal;
clear sweep
sweep.sweepVector = sweepDetuning;
sweep.ampNorm = zeros(length(sweepDetuning),length(x.gateLists));
cardparams.averages=20;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring

for ind = 1:length(sweepDetuning)
   clear x;
   x = explib.ArbSequence(pulseCal,gateLists,softwareAverages);
   
   %change a parameter
   x.pulseCal.Y90Azimuth = sweepDetuning(ind);
   x.update();
   
   tic; playlist = x.directDownloadM8195A(awg); toc
   tic; time=fix(clock);
   result = x.directRunM8195A(awg,card,cardparams,playlist); toc
   sweep.ampNorm(ind,:) = result.AmpNorm;
   
   figure(555)
%    plot(result.xaxisNorm,sweep.ampNorm(ind,:),'-o')
      imagesc(result.xaxisNorm,(sweep.sweepVector(1:ind).*180./pi-90),sweep.ampNorm(1:ind,:))
%    set(gca,'xtick',(1:length(x.seqNames)));
%    set(gca,'xticklabel',x.seqNames);
%    ax = gca;
%    ax.XTickLabelRotation=45;
%    plotlib.hline(1);
%    plotlib.hline(.5);
%    plotlib.hline(0);
   title('Sweeping ArbErrorAmp')
   ylabel('Y90 Azimuth Offset');xlabel('numRepeats')
   drawnow
end
save(['C:\Data\ArbErrorAmp' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'sweep','result');

%% sweep X180 azimuth
% Repeated gate sequence should be [2 6] = X180Y90
% sweepDetuning = linspace(80*pi/180,100*pi/180,21);
sweepDetuning = linspace(1.2*pi/180,2.2*pi/180,21);
initialPulseCal = pulseCal;
clear sweep
sweep.sweepVector = sweepDetuning;
sweep.ampNorm = zeros(length(sweepDetuning),length(x.gateLists));
cardparams.averages=20;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring

for ind = 1:length(sweepDetuning)
   clear x;
   x = explib.ArbSequence(pulseCal,gateLists,softwareAverages);
   
   %change a parameter
   x.pulseCal.X180Azimuth = sweepDetuning(ind);
   x.update();
   
   tic; playlist = x.directDownloadM8195A(awg); toc
   tic; time=fix(clock);
   result = x.directRunM8195A(awg,card,cardparams,playlist); toc
   sweep.ampNorm(ind,:) = result.AmpNorm;
   
   figure(555)
%    plot(result.xaxisNorm,sweep.ampNorm(ind,:),'-o')
      imagesc(result.xaxisNorm,(sweep.sweepVector(1:ind).*180./pi),sweep.ampNorm(1:ind,:))
%    set(gca,'xtick',(1:length(x.seqNames)));
%    set(gca,'xticklabel',x.seqNames);
%    ax = gca;
%    ax.XTickLabelRotation=45;
%    plotlib.hline(1);
%    plotlib.hline(.5);
%    plotlib.hline(0);
   title('Sweeping ArbErrorAmp')
   ylabel('X180 Azimuth Offset');xlabel('numRepeats')
   drawnow
end
save(['C:\Data\ArbErrorAmp' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'sweep','result');
%% sweep Y180 azimuth
% Repeated gate sequence should be [5 3] = Y180X90
% sweepDetuning = linspace(80*pi/180,100*pi/180,21);
sweepDetuning = linspace(90.5*pi/180,91.5*pi/180,21);
initialPulseCal = pulseCal;
clear sweep
sweep.sweepVector = sweepDetuning;
sweep.ampNorm = zeros(length(sweepDetuning),length(x.gateLists));
cardparams.averages=20;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring

for ind = 1:length(sweepDetuning)
   clear x;
   x = explib.ArbSequence(pulseCal,gateLists,softwareAverages);
   
   %change a parameter
   x.pulseCal.Y180Azimuth = sweepDetuning(ind);
   x.update();
   
   tic; playlist = x.directDownloadM8195A(awg); toc
   tic; time=fix(clock);
   result = x.directRunM8195A(awg,card,cardparams,playlist); toc
   sweep.ampNorm(ind,:) = result.AmpNorm;
   
   figure(555)
%    plot(result.xaxisNorm,sweep.ampNorm(ind,:),'-o')
      imagesc(result.xaxisNorm,(sweep.sweepVector(1:ind).*180./pi),sweep.ampNorm(1:ind,:))
%    set(gca,'xtick',(1:length(x.seqNames)));
%    set(gca,'xticklabel',x.seqNames);
%    ax = gca;
%    ax.XTickLabelRotation=45;
%    plotlib.hline(1);
%    plotlib.hline(.5);
%    plotlib.hline(0);
   title(['Sweeping ArbErrorAmp '  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))] )
   ylabel('X180 Azimuth Offset');xlabel('numRepeats')
   drawnow
end
save(['C:\Data\ArbErrorAmp' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'sweep','result');





