%% Step 1, set up pulsecal with initial values
% Create pulseCal object - NOTE: pulseCal objects are VALUE objects not HANDLE objects
% initialPulseCal = paramlib.pulseCal();
% % generic qubit pulse properties
% initialPulseCal.qubitFreq = 4.772869998748302e9;
% initialPulseCal.sigma = 4e-9;
% initialPulseCal.cutoff = 4*initialPulseCal.sigma;
% initialPulseCal.buffer = 4e-9;
% % measurement pulse properties
% initialPulseCal.cavityFreq = 10.16578e9;
% initialPulseCal.cavityAmplitude = 0.3;
% initialPulseCal.measDuration = 10e-6; % length of measurement pulse
% % waveform properties
% initialPulseCal.startBuffer = 5e-6; % delay after start before qubit pulses can occur
% initialPulseCal.measBuffer = 200e-9; % delay btw final qubit pulse and measurement pulse
% initialPulseCal.endBuffer = 5e-6; % buffer after measurement pulse
% initialPulseCal.samplingRate=32e9;
% % acquisition properties
% initialPulseCal.integrationStartIndex = 1; % start point for integration of acquisition card data
% initialPulseCal.integrationStopIndex = 10000; % stoppoint for integration of acquisition card data
% initialPulseCal.cardDelayOffset = 1.5e-6; % time delay AFTER measurement pulse to start acquisition
% USAGE: cardparams.delaytime = experimentObject.measStartTime + acquisition.cardDelayOffset;
% gate specific properties
% initialPulseCal.X90Amplitude =.3354; 
% initialPulseCal.X90DragAmplitude = .044302;
% initialPulseCal.Xm90Amplitude = initialPulseCal.X90Amplitude;
% initialPulseCal.Xm90DragAmplitude = initialPulseCal.X90DragAmplitude;
% initialPulseCal.X180Amplitude = .68518;
% initialPulseCal.X180DragAmplitude = .064985;
% initialPulseCal.Xm180Amplitude = initialPulseCal.X180Amplitude;
% initialPulseCal.Xm180DragAmplitude = initialPulseCal.X180DragAmplitude;
% initialPulseCal.Y90Amplitude = .33353;
% initialPulseCal.Y90DragAmplitude = -0.039424;
% initialPulseCal.Ym90Amplitude = initialPulseCal.Y90Amplitude;
% initialPulseCal.Ym90DragAmplitude = initialPulseCal.Y90DragAmplitude;
% initialPulseCal.Y180Amplitude = .68471;
% initialPulseCal.Y180DragAmplitude = -0.06357;
% initialPulseCal.Ym180Amplitude = initialPulseCal.Y180Amplitude;
% initialPulseCal.Ym180DragAmplitude = initialPulseCal.Y180DragAmplitude;

initialPulseCal.X90Amplitude =.35; 
initialPulseCal.X90DragAmplitude = .00;
initialPulseCal.Xm90Amplitude = initialPulseCal.X90Amplitude;
initialPulseCal.Xm90DragAmplitude = initialPulseCal.X90DragAmplitude;
initialPulseCal.X180Amplitude = .7;
initialPulseCal.X180DragAmplitude = .0;
initialPulseCal.Xm180Amplitude = initialPulseCal.X180Amplitude;
initialPulseCal.Xm180DragAmplitude = initialPulseCal.X180DragAmplitude;
initialPulseCal.Y90Amplitude = .35;
initialPulseCal.Y90DragAmplitude = 0;
initialPulseCal.Ym90Amplitude = initialPulseCal.Y90Amplitude;
initialPulseCal.Ym90DragAmplitude = initialPulseCal.Y90DragAmplitude;
initialPulseCal.Y180Amplitude = .7;
initialPulseCal.Y180DragAmplitude = .0;
initialPulseCal.Ym180Amplitude = initialPulseCal.Y180Amplitude;
initialPulseCal.Ym180DragAmplitude = initialPulseCal.Y180DragAmplitude;


%% Step 2 - rough X180, X90 amplitude calibration with rabi
display(' ')
display(' ')
display('Step 2 - rough X180, X90 amplitude calibration with rabi')
updatedPulseCal = initialPulseCal;
totalCalTime = tic;
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
ampVector = linspace(0,1,26);
softwareAverages = 10; 
x = explib.X180RabiExperiment(updatedPulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
% update x180 and x90 amp to prepare for the error amplification routine    
display(['Old X180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
updatedPulseCal.X180Amplitude = result.newAmp;
updatedPulseCal.X90Amplitude = result.newAmp/2;
display(['New X180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
toc
%% Step 3 - fine X90 amp cal using error amplification
display(' ')
display(' ')
display('Step 3 - fine X90 amp cal using error amplification')
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:2:40; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 20; 
x = explib.X90AmpCal(updatedPulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
display(['Old X90, Xm90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
updatedPulseCal.X90Amplitude = result.newAmp;
updatedPulseCal.Xm90Amplitude = result.newAmp;
display(['New X90, Xm90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
toc

%% Step 4 - X90 Drag cal
display(' ')
display(' ')
display('Step 4 - X90 Drag cal')
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
ampVector = linspace(-.4,.4,51);
softwareAverages = 30; 
x = explib.X90DragCal(updatedPulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
toc; 
time=fix(clock);
result = x.directRunM8195A(awg,card,cardparams,playlist);
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
display(['Old X90, Xm90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
updatedPulseCal.X90DragAmplitude = result.newDragAmp;
updatedPulseCal.Xm90DragAmplitude = result.newDragAmp;
display(['New X90, Xm90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
toc

%% Step 5 - very fine X90 amp cal using error amplification
display(' ')
display(' ')
display('Step 5 - very fine X90 amp cal using error amplification')
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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
display(['Old X90, Xm90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
updatedPulseCal.X90Amplitude = result.newAmp;
updatedPulseCal.Xm90Amplitude = result.newAmp;
display(['New X90, Xm90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
toc

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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
display(['Old X90, Xm90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
updatedPulseCal.X90Amplitude = result.newAmp;
updatedPulseCal.Xm90Amplitude = result.newAmp;
display(['New X90, Xm90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
toc
display(['Total Calibration Time: '])
toc(totalCalTime)

%% Step 8 - X90 is calibrated, use these values to update other pulses
updatedPulseCal.Y90Amplitude = updatedPulseCal.X90Amplitude;
updatedPulseCal.Y90DragAmplitude = -1*updatedPulseCal.X90DragAmplitude;
updatedPulseCal.Ym90Amplitude = updatedPulseCal.X90Amplitude;
updatedPulseCal.Ym90DragAmplitude = -1*updatedPulseCal.X90DragAmplitude;
updatedPulseCal.X180Amplitude = 2*updatedPulseCal.X90Amplitude;
updatedPulseCal.X180DragAmplitude = 2*updatedPulseCal.X90DragAmplitude;
updatedPulseCal.Xm180Amplitude = 2*updatedPulseCal.X90Amplitude;
updatedPulseCal.Xm180DragAmplitude = 2*updatedPulseCal.X90DragAmplitude;
updatedPulseCal.Y180Amplitude = 2*updatedPulseCal.X90Amplitude;
updatedPulseCal.Y180DragAmplitude = -2*updatedPulseCal.X90DragAmplitude;
updatedPulseCal.Ym180Amplitude = 2*updatedPulseCal.X90Amplitude;
updatedPulseCal.Ym180DragAmplitude = -2*updatedPulseCal.X90DragAmplitude;

%% Step 9 - very fine X180 amp cal using error amplification
display(' ')
display(' ')
display('Step 9 - very fine X180 amp cal using error amplification')
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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
display(['Old X180, Xm180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
updatedPulseCal.X180Amplitude = result.newAmp;
updatedPulseCal.Xm180Amplitude = result.newAmp;
display(['New X180, Xm180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
toc

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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
display(['Old X180, Xm180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
updatedPulseCal.X180Amplitude = result.newAmp;
updatedPulseCal.Xm180Amplitude = result.newAmp;
display(['New X180, Xm180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
toc

%% Step 12 - X180 is calibrated, use these values to update other pulses
updatedPulseCal.Y180Amplitude = updatedPulseCal.X180Amplitude;
updatedPulseCal.Y180DragAmplitude = -1*updatedPulseCal.X180DragAmplitude;
updatedPulseCal.Ym180Amplitude = updatedPulseCal.X180Amplitude;
updatedPulseCal.Ym180DragAmplitude = -1*updatedPulseCal.X180DragAmplitude;

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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
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
save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
display(['Old Y180, Ym180 Amplitude: ' num2str(updatedPulseCal.Y180Amplitude)])
updatedPulseCal.Y180Amplitude = result.newAmp;
updatedPulseCal.Ym180Amplitude = result.newAmp;
display(['New Y180, Ym180 Amplitude: ' num2str(updatedPulseCal.Y180Amplitude)])
toc
display(['Total Calibration Time: '])
toc(totalCalTime)


%%  
pulseCal = updatedPulseCal;
