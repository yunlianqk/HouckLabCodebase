%% Step 1, set up pulsecal with initial values
% Create pulseCal object - NOTE: pulseCal objects are VALUE objects not HANDLE objects
pulseCal = paramlib.pulseCal();
% generic qubit pulse properties
pulseCal.qubitFreq = 7.5e9;
pulseCal.sigma = 4e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.buffer = 4e-9;
% measurement pulse properties
pulseCal.cavityFreq=5.823e9; % cavity frequency
pulseCal.cavityAmplitude = 0.6;
pulseCal.measDuration = 10e-6; % length of measurement pulse
% waveform properties
pulseCal.startBuffer = 5e-6; % delay after start before qubit pulses can occur
pulseCal.measBuffer = 200e-9; % delay btw final qubit pulse and measurement pulse
pulseCal.endBuffer = 5e-6; % buffer after measurement pulse
pulseCal.samplingRate=32e9;
% acquisition properties
pulseCal.integrationStartIndex = 1; % start point for integration of acquisition card data
pulseCal.integrationStopIndex = 10000; % stoppoint for integration of acquisition card data
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
ampVector = linspace(0,1,26);
softwareAverages = 5; 
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


%% X90 Drag cal
display(' ')
display(' ')
display('X90 Drag cal')
cardparams.averages=50; 
card.SetParams(cardparams);
ampVector = linspace(-.4,.4,51);
softwareAverages = 10; 
x = explib.X90DragCal(pulseCal, ampVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old X90, Xm90 Drag Amplitude: ' num2str(pulseCal.X90DragAmplitude)])
pulseCal.X90DragAmplitude = result.newDragAmp;
pulseCal.Xm90DragAmplitude = result.newDragAmp;
pulseCal.Y90DragAmplitude = -1*result.newDragAmp;
pulseCal.Ym90DragAmplitude = -1*result.newDragAmp;
display(['New X90, Xm90 Drag Amplitude: ' num2str(pulseCal.X90DragAmplitude)])


%% very fine X90 amp cal using error amplification
display(' ')
display(' ')
display('very fine X90 amp cal using error amplification')
cardparams.averages=50; 
card.SetParams(cardparams);
numGateVector = 0:2:80; % list of # of pi/2 gates to be done. MUST BE EVEN
softwareAverages = 20; 
x = explib.X90AmpCal(pulseCal, numGateVector, softwareAverages);
playlist = x.directDownloadM8195A(awg);
result = x.directRunM8195A(awg,card,cardparams,playlist);
display(['Old X90, Xm90 Amplitude: ' num2str(pulseCal.X90Amplitude)])
pulseCal.X90Amplitude = result.newAmp;
pulseCal.Xm90Amplitude = result.newAmp;
pulseCal.Y90Amplitude = result.newAmp;
pulseCal.Ym90Amplitude = result.newAmp;
display(['New X90, Xm90 Amplitude: ' num2str(pulseCal.X90Amplitude)])

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

