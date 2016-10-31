% Cliff Check for a range of Clifford gates
sweep.numCliffs = 1:5:100;
sweep.ampNorm = zeros(length(sweep.numCliffs),24);

cardparams.averages=20;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring
for ind = 1:length(sweep.numCliffs)
   clear x;
   x=explib.CliffordCheck(pulseCal);
   x.numCliffs = sweep.numCliffs(ind);
   x.update();
   
   tic; playlist = x.directDownloadM8195A(awg); toc
   tic; time=fix(clock);
   result = x.directRunM8195A(awg,card,cardparams,playlist); toc
   sweep.ampNorm(ind,:) = result.AmpNorm;
   
   pause(0.1);
   figure(555)
   imagesc(result.xaxisNorm,sweep.numCliffs(1:ind),sweep.ampNorm(1:ind,:))
   title('Clifford error amplification')
   ylabel('Number of Clifford gates');xlabel('Clifford number')
   drawnow
end