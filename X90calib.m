%  pulseCal.X90Amplitude=0.35;
 
 display(' ')
display(' ')
display('fine X90 amp cal using error amplification')
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:2:40; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 10; 
x = explib.X90AmpCal(pulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old X90, Xm90 Amplitude: ' num2str(pulseCal.X90Amplitude)])
pulseCal.X90Amplitude = result.newAmp;
pulseCal.Xm90Amplitude = result.newAmp;
pulseCal.Y90Amplitude = result.newAmp;
pulseCal.Ym90Amplitude = result.newAmp;
display(['New X90, Xm90 Amplitude: ' num2str(pulseCal.X90Amplitude)])


%%
%  pulseCal.X90Amplitude=0.35;
 
cardparams.averages=50; 
card.SetParams(cardparams);
ampVector = linspace(0,1,51);
softwareAverages = 50; 
x = explib.X90RabiExperiment(pulseCal,ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
