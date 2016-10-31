% sweep AllXY vs Detuning
% code to sweep various parameters
x=explib.AllXY(pulseCal);
sweepVector = linspace(-3e6,3e6,10);
initialPulseCal = pulseCal;
sweep.sweepVector = sweepVector;
sweep.ampNorm = zeros(length(sweepVector),length(x.gateLists));
cardparams.averages=20;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring

for ind = 1:length(sweepVector)
   clear x;
   x=explib.AllXY(pulseCal);
   
   %change a parameter
   x.pulseCal.qubitFreq = initialPulseCal.qubitFreq+sweepVector(ind);
   x.update();
   
   tic; playlist = x.directDownloadM8195A(awg); toc
   tic; time=fix(clock);
   result = x.directRunM8195A(awg,card,cardparams,playlist); toc
   sweep.ampNorm(ind,:) = result.AmpNorm;
   
   figure(555)
   plot(result.xaxisNorm,sweep.ampNorm(ind,:),'-o')
   %    imagesc(result.xaxisNorm,sweep.numCliffs(1:ind),sweep.ampNorm(1:ind,:))
   set(gca,'xtick',(1:length(x.seqNames)));
   set(gca,'xticklabel',x.seqNames);
   ax = gca;
   ax.XTickLabelRotation=45;
   plotlib.hline(1);
   plotlib.hline(-1);
   plotlib.hline(0);
   title('Sweeping AllXY')
   ylabel('Z projection');xlabel('gates')
   drawnow
   hold on
end

%%
% sweep AllXY vs Amplitude
% code to sweep various parameters
x=explib.AllXY(pulseCal);
sweepVector = linspace(0.95,1.05,11);    % scale factor
initialpulseCal = pulseCal;
sweep.sweepVector = sweepVector;
sweep.ampNorm = zeros(length(sweepVector),length(x.gateLists));
cardparams.averages=20;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring

% plot parameters
legend_name=cell(1,length(sweepVector));
cmap = colormap(jet(length(sweepVector)));

for ind = 1:length(sweepVector)
   clear x;
   x=explib.AllXY(pulseCal);
   zeroGate = x.zeroGate;
   oneGate = x.oneGate;
   
   %change a parameter
%    x.pulseCal.qubitFreq = initialPulseCal.qubitFreq+sweepVector(ind);
   x.pulseCal.X180Amplitude = sweepVector(ind)*initialpulseCal.X180Amplitude;
   x.pulseCal.Xm180Amplitude = sweepVector(ind)*initialpulseCal.Xm180Amplitude;
   x.pulseCal.X90Amplitude = sweepVector(ind)*initialpulseCal.X90Amplitude;
   x.pulseCal.Xm90Amplitude = sweepVector(ind)*initialpulseCal.Xm90Amplitude;
   x.pulseCal.Y180Amplitude = sweepVector(ind)*initialpulseCal.Y180Amplitude;
   x.pulseCal.Ym180Amplitude = sweepVector(ind)*initialpulseCal.Ym180Amplitude;
   x.pulseCal.Y90Amplitude = sweepVector(ind)*initialpulseCal.Y90Amplitude;
   x.pulseCal.Ym90Amplitude = sweepVector(ind)*initialpulseCal.Ym90Amplitude;
   
   x.update();
   x.zeroGate = zeroGate;
   x.oneGate = oneGate;
   
   tic; playlist = x.directDownloadM8195A(awg); toc
   tic; time=fix(clock);
   result = x.directRunM8195A(awg,card,cardparams,playlist); toc
   sweep.ampNorm(ind,:) = result.AmpNorm;
   
   figure(555)
   plot(result.xaxisNorm,sweep.ampNorm(ind,:),'-o',...
       'LineWidth',1.5,...
       'Color',cmap(ind,:),...
       'MarkerEdgeColor','k',...
       'MarkerSize',8,...
       'MarkerFaceColor',cmap(ind,:));
   %    imagesc(result.xaxisNorm,sweep.numCliffs(1:ind),sweep.ampNorm(1:ind,:))
   set(gca,'xtick',(1:length(x.seqNames)));
   set(gca,'xticklabel',x.seqNames);
   ax = gca;
   ax.XTickLabelRotation=45;
   plotlib.hline(1);
   plotlib.hline(-1);
   plotlib.hline(0);
   title('Sweeping AllXY')
   ylabel('Z projection');xlabel('gates')  
   legend_name{ind}=num2str(sweepVector(ind));
   legend(legend_name(1:ind))
   drawnow
   hold on
end
