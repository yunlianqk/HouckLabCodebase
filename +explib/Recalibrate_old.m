updatedPulseCal=pulseCal;
totalCalTime = tic;
%% Step 6 - fine X90 Drag cal
display(' ')
display(' ')
display('Step 6 - fine X90 Drag cal')
tic; 
cardparams.averages=25; 
card.SetParams(cardparams);
ampVector = linspace(-.4,.4,101);
softwareAverages = 40; 
x = explib.X90DragCal(updatedPulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
% save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%         'x', 'awg', 'cardparams', 'result');
display(['Old X90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
updatedPulseCal.X90DragAmplitude = result.newDragAmp;
updatedPulseCal.Xm90DragAmplitude = result.newDragAmp;
updatedPulseCal.Y90DragAmplitude = -1*result.newDragAmp;
updatedPulseCal.Ym90DragAmplitude = -1*result.newDragAmp;
display(['New X90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
toc

%% Step 7 - final very fine X90 amp cal using error amplification
display(' ')
display(' ')
display('Step 7 - final very fine X90 amp cal using error amplification')
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:2:80; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 20; 
x = explib.X90AmpCal(updatedPulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
% save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%         'x', 'awg', 'cardparams', 'result');
display(['Old X90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
updatedPulseCal.X90Amplitude = result.newAmp;
updatedPulseCal.Xm90Amplitude = result.newAmp;
updatedPulseCal.Y90Amplitude = result.newAmp;
updatedPulseCal.Ym90Amplitude = result.newAmp;
display(['New X90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
toc
display(['Total Calibration Time: '])
toc(totalCalTime)

%% Step 10 - fine X180 Drag cal
display(' ')
display(' ')
display('Step 10 - fine X180 Drag cal')
tic; 
cardparams.averages=25; 
card.SetParams(cardparams);
ampVector = linspace(-.4,.4,101);
softwareAverages = 40; 
x = explib.X180DragCal(updatedPulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
% save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%         'x', 'awg', 'cardparams', 'result');
display(['Old X180 Drag Amplitude: ' num2str(updatedPulseCal.X180DragAmplitude)])
updatedPulseCal.X180DragAmplitude = result.newDragAmp;
updatedPulseCal.Xm180DragAmplitude = result.newDragAmp;
updatedPulseCal.Y180DragAmplitude = -1*result.newDragAmp;
updatedPulseCal.Ym180DragAmplitude = -1*result.newDragAmp;
display(['New X180 Drag Amplitude: ' num2str(updatedPulseCal.X180DragAmplitude)])
toc

%% Step 11 - final very fine X180 amp cal using error amplification
display(' ')
display(' ')
display('Step 11 - very fine X180 amp cal using error amplification')
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:1:40; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 20; 
x = explib.X180AmpCal(updatedPulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
% save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%         'x', 'awg', 'cardparams', 'result');
display(['Old X180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
updatedPulseCal.X180Amplitude = result.newAmp;
updatedPulseCal.Xm180Amplitude = result.newAmp;
updatedPulseCal.Y180Amplitude = result.newAmp;
updatedPulseCal.Ym180Amplitude = result.newAmp;
display(['New X180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
toc

%%  
display(['Total Calibration Time: '])
toc(totalCalTime)
pulseCal = updatedPulseCal;
