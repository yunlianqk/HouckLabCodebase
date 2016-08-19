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
display(['Old X90, Xm90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
updatedPulseCal.X90DragAmplitude = result.newDragAmp;
updatedPulseCal.Xm90DragAmplitude = result.newDragAmp;
display(['New X90, Xm90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
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
display(['Old X90, Xm90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
updatedPulseCal.X90Amplitude = result.newAmp;
updatedPulseCal.Xm90Amplitude = result.newAmp;
display(['New X90, Xm90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
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
display(['Old X180, Xm180 Drag Amplitude: ' num2str(updatedPulseCal.X180DragAmplitude)])
updatedPulseCal.X180DragAmplitude = result.newDragAmp;
updatedPulseCal.Xm180DragAmplitude = result.newDragAmp;
display(['New X180, Xm180 Drag Amplitude: ' num2str(updatedPulseCal.X180DragAmplitude)])
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
display(['Old X180, Xm180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
updatedPulseCal.X180Amplitude = result.newAmp;
updatedPulseCal.Xm180Amplitude = result.newAmp;
display(['New X180, Xm180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
toc

%% Step 13 - fine Y90 Drag cal
display(' ')
display(' ')
display('Step 13 - fine Y90 Drag cal')
tic; 
cardparams.averages=25; 
card.SetParams(cardparams);
ampVector = linspace(-.4,.4,101);
softwareAverages = 40; 
x = explib.Y90DragCal(updatedPulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
% save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%         'x', 'awg', 'cardparams', 'result');
display(['Old Y90, Ym90 Drag Amplitude: ' num2str(updatedPulseCal.Y90DragAmplitude)])
updatedPulseCal.Y90DragAmplitude = result.newDragAmp;
updatedPulseCal.Ym90DragAmplitude = result.newDragAmp;
display(['New Y90, Ym90 Drag Amplitude: ' num2str(updatedPulseCal.Y90DragAmplitude)])
toc

%% Step 14 - final very fine Y90 amp cal using error amplification
display(' ')
display(' ')
display('Step 14 - final very fine Y90 amp cal using error amplification')
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:2:80; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 20; 
x = explib.Y90AmpCal(updatedPulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
% save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%         'x', 'awg', 'cardparams', 'result');
display(['Old Y90, Ym90 Amplitude: ' num2str(updatedPulseCal.Y90Amplitude)])
updatedPulseCal.Y90Amplitude = result.newAmp;
updatedPulseCal.Ym90Amplitude = result.newAmp;
display(['New Y90, Ym90 Amplitude: ' num2str(updatedPulseCal.Y90Amplitude)])
toc


%% Step 15 - fine Y180 Drag cal
display(' ')
display(' ')
display('Step 15 - fine Y180 Drag cal')
tic; 
cardparams.averages=25; 
card.SetParams(cardparams);
ampVector = linspace(-.4,.4,101);
softwareAverages = 40; 
x = explib.Y180DragCal(updatedPulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
% save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%         'x', 'awg', 'cardparams', 'result');
display(['Old Y180, Ym180 Drag Amplitude: ' num2str(updatedPulseCal.Y180DragAmplitude)])
updatedPulseCal.Y180DragAmplitude = result.newDragAmp;
updatedPulseCal.Ym180DragAmplitude = result.newDragAmp;
display(['New Y180, Ym180 Drag Amplitude: ' num2str(updatedPulseCal.Y180DragAmplitude)])
toc

%% Step 16 - final very fine Y180 amp cal using error amplification
display(' ')
display(' ')
display('Step 16 - very fine Y180 amp cal using error amplification')
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:1:40; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 20; 
x = explib.Y180AmpCal(updatedPulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
% save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%         'x', 'awg', 'cardparams', 'result');
display(['Old Y180, Ym180 Amplitude: ' num2str(updatedPulseCal.Y180Amplitude)])
updatedPulseCal.Y180Amplitude = result.newAmp;
updatedPulseCal.Ym180Amplitude = result.newAmp;
display(['New Y180, Ym180 Amplitude: ' num2str(updatedPulseCal.Y180Amplitude)])
toc

%%  
display(['Total Calibration Time: '])
toc(totalCalTime)
pulseCal = updatedPulseCal;
