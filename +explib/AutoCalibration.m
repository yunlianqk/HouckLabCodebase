%% Step 1, set up pulsecal with initial values
% Create pulseCal object - NOTE: pulseCal objects are VALUE objects not HANDLE objects
pulseCal = paramlib.pulseCal();
% generic qubit pulse properties
pulseCal.qubitFreq = 4.791*1e9;
pulseCal.sigma = 4e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.buffer = 4e-9;
% measurement pulse properties
pulseCal.cavityFreq=10.165600e9; % cavity frequency
pulseCal.cavityAmplitude = 0.6;
pulseCal.measDuration = 10e-6; % length of measurement pulse
% waveform properties
pulseCal.startBuffer = 5e-6; % delay after start before qubit pulses can occur
pulseCal.measBuffer = 200e-9; % delay btw final qubit pulse and measurement pulse
pulseCal.endBuffer = 5e-6; % buffer after measurement pulse
pulseCal.samplingRate=32e9;
% acquisition properties
pulseCal.integrationStartIndex = 1; % start point for integration of acquisition card data
pulseCal.integrationStopIndex = 5000; % stoppoint for integration of acquisition card data
pulseCal.cardDelayOffset = 1.5e-6; % time delay AFTER measurement pulse to start acquisition
% USAGE: cardparams.delaytime = experimentObject.measStartTime + acquisition.cardDelayOffset;
% gate specific properties

pulseCal.X90Amplitude =.28; 
pulseCal.X90DragAmplitude = .00;
pulseCal.Xm90Amplitude = pulseCal.X90Amplitude;
pulseCal.Xm90DragAmplitude = pulseCal.X90DragAmplitude;
pulseCal.X180Amplitude = .6;
pulseCal.X180DragAmplitude = .0;
pulseCal.Xm180Amplitude = pulseCal.X180Amplitude;
pulseCal.Xm180DragAmplitude = pulseCal.X180DragAmplitude;
pulseCal.Y90Amplitude = .35;
pulseCal.Y90DragAmplitude = 0;
pulseCal.Ym90Amplitude = pulseCal.Y90Amplitude;
pulseCal.Ym90DragAmplitude = pulseCal.Y90DragAmplitude;
pulseCal.Y180Amplitude = .7;
pulseCal.Y180DragAmplitude = .0;
pulseCal.Ym180Amplitude = pulseCal.Y180Amplitude;
pulseCal.Ym180DragAmplitude = pulseCal.Y180DragAmplitude;

%%
display(' ')
display(' ')
display('X180 Rabi')
cardparams.averages=50; 
card.SetParams(cardparams);
% ampVector = linspace(0,1,26);
ampVector = linspace(0,1,51);
softwareAverages = 10; 
x = explib.X180RabiExperiment(pulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg); 
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old X180 Amplitude: ' num2str(pulseCal.X180Amplitude)])
pulseCal.X180Amplitude = result.newAmp;
pulseCal.X90Amplitude = result.newAmp/2;
pulseCal.Xm90Amplitude = result.newAmp/2;
pulseCal.Y180Amplitude = result.newAmp;
pulseCal.Y90Amplitude = result.newAmp/2;
pulseCal.Ym90Amplitude = result.newAmp/2;
display(['New X180 Amplitude: ' num2str(pulseCal.X180Amplitude)])

%% fine X90 amp cal using error amplification
display(' ')
display(' ')
display('fine X90 amp cal using error amplification')
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:2:80; % list of # of pi/2 gates to be done. MUST BE EVEN
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


%% X90 Drag cal
display(' ')
display(' ')
display('X90 Drag cal')
cardparams.averages=50; 
card.SetParams(cardparams);
ampVector = linspace(-.2,.2,51);
softwareAverages = 20; 
x = explib.X90DragCal(pulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old X90, Xm90 Drag Amplitude: ' num2str(pulseCal.X90DragAmplitude)])
pulseCal.X90DragAmplitude = result.newDragAmp;
pulseCal.Xm90DragAmplitude = result.newDragAmp;
pulseCal.Y90DragAmplitude = -1*result.newDragAmp;
pulseCal.Ym90DragAmplitude = -1*result.newDragAmp;
display(['New X90, Xm90 Drag Amplitude: ' num2str(pulseCal.X90DragAmplitude)])

%% very fine X180 amp cal using error amplification
display(' ')
display(' ')
display('very fine X180 amp cal using error amplification')
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:1:40; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 10; 
x = explib.X180AmpCal(pulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old X180, Xm180 Amplitude: ' num2str(pulseCal.X180Amplitude)])
pulseCal.X180Amplitude = result.newAmp;
pulseCal.Xm180Amplitude = result.newAmp;
pulseCal.Y180Amplitude = result.newAmp;
pulseCal.Ym180Amplitude = result.newAmp;
display(['New X180, Xm180 Amplitude: ' num2str(pulseCal.X180Amplitude)])

%% X180 Drag cal
display(' ')
display(' ')
display('X180 Drag cal')
cardparams.averages=50; 
card.SetParams(cardparams);
ampVector = linspace(-.2,.3,51);
softwareAverages = 20; 
x = explib.X180DragCal(pulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old X180, Xm180 Drag Amplitude: ' num2str(pulseCal.X180DragAmplitude)])
pulseCal.X180DragAmplitude = result.newDragAmp;
pulseCal.Xm180DragAmplitude = result.newDragAmp;
pulseCal.Y180DragAmplitude = -1*result.newDragAmp;
pulseCal.Ym180DragAmplitude = -1*result.newDragAmp;
display(['New X180, Xm180 Drag Amplitude: ' num2str(pulseCal.X180DragAmplitude)])
%% ================================
% Calibrate the Y gates
% fine Y90 amp cal using error amplification
display(' ')
display(' ')
display('fine X90 amp cal using error amplification')
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:2:40; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 10; 
x = explib.Y90AmpCal(pulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old Y90, Ym90 Amplitude: ' num2str(pulseCal.Y90Amplitude)])
pulseCal.Y90Amplitude = result.newAmp;
pulseCal.Ym90Amplitude = result.newAmp;
display(['New Y90, Ym90 Amplitude: ' num2str(pulseCal.Y90Amplitude)])

%% Y90 drag cal
display(' ')
display(' ')
display('Y90 Drag cal')
cardparams.averages=50; 
card.SetParams(cardparams);
ampVector = linspace(-.2,.2,51);
softwareAverages = 20; 
x = explib.Y90DragCal(pulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old Y90, Xm90 Drag Amplitude: ' num2str(pulseCal.Y90DragAmplitude)])
pulseCal.Y90DragAmplitude = result.newDragAmp;
pulseCal.Ym90DragAmplitude = result.newDragAmp;
display(['New Y90, Xm90 Drag Amplitude: ' num2str(pulseCal.Y90DragAmplitude)])

%% very fine Y180 amp cal using error amplification
display(' ')
display(' ')
display('very fine Y180 amp cal using error amplification')
tic; 
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:1:40; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 10; 
x = explib.Y180AmpCal(pulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old Y180, Ym180 Amplitude: ' num2str(pulseCal.Y180Amplitude)])
pulseCal.Y180Amplitude = result.newAmp;
pulseCal.Ym180Amplitude = result.newAmp;
display(['New Y180, Ym180 Amplitude: ' num2str(pulseCal.Y180Amplitude)])

%% Y180 Drag cal
display(' ')
display(' ')
display('Y180 Drag cal')
cardparams.averages=50; 
card.SetParams(cardparams);
ampVector = linspace(-.2,.2,51);
softwareAverages = 20; 
x = explib.Y180DragCal(pulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old Y180, Ym180 Drag Amplitude: ' num2str(pulseCal.Y180DragAmplitude)])
pulseCal.Y180DragAmplitude = result.newDragAmp;
pulseCal.Ym180DragAmplitude = result.newDragAmp;
display(['New Y180, Ym180 Drag Amplitude: ' num2str(pulseCal.Y180DragAmplitude)])
