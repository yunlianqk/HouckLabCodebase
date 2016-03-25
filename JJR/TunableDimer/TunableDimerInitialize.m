% Add tunable dimer folder to path
cd('C:\Users\HouckLab\Documents\GitHub\JJR\TunableDimer')
path = pwd;
addpath(genpath(path));
cd('C:\Users\HouckLab\Documents\GitHub\HouckLabMeasurementCode')
oxfordInstrumentsInitialize
cd('C:\Users\HouckLab\Documents\GitHub\JJR\TunableDimer')

%add legacy code for controlling pnax using old style
% addpath(genpath('C:\Users\HouckLab\Documents\MATLAB\Immaculate Sweep\JamesCode\jjroxfordcode'));
% addpath(genpath('C:\Users\HouckLab\Documents\MATLAB\Immaculate Sweep\Analyzers'));

%% initialize channel 1 for transmission measurement of amp and phase
pnax.SetTransParams();
pnax.transparams.trace = 2;
pnax.transparams.format = 'UPH';
pnax.SetTransParams();
pause(1);
pnax.SetActiveTrace(1);
transamp = pnax.Read();
pnax.SetActiveTrace(2);
transph = pnax.Read();
freqvector = pnax.GetAxis();
figure(1);
subplot(2,1,1);
plot(freqvector/1e9, transamp);
title('Amplitude');
subplot(2,1,2);
plot(freqvector/1e9, transph);
title('Phase');
xlabel('Frequency (GHz)');

%% initialize channel 2 for spec scan amp and phase
pnax.SetSpecParams();
% Phase trace
pnax.specparams.trace = 4;
pnax.specparams.format = 'UPH';
pnax.SetSpecParams();
% Read data
pause(1);
pnax.SetActiveTrace(3);
specamp = pnax.Read();
pnax.SetActiveTrace(4);
specph = pnax.Read();
freqvector = pnax.GetAxis();
figure(2);
subplot(2,1,1);
plot(freqvector/1e9, specamp);
title('Amplitude');
subplot(2,1,2);
plot(freqvector/1e9, specph);
title('Phase');
xlabel('Spec frequency (GHz)');

%% S41 
pnax.SetS41TransParams();
% Phase trace
pnax.S41transparams.trace = 6;
pnax.S41transparams.format = 'UPH';
pnax.SetS41TransParams();
% Read data
pause(1);
pnax.SetActiveTrace(5);
S41transamp = pnax.Read();
pnax.SetActiveTrace(6);
S41transph = pnax.Read();
freqvector = pnax.GetAxis();
figure(1);
subplot(2,1,1);
plot(freqvector/1e9, S41transamp);
title('Amplitude');
subplot(2,1,2);
plot(freqvector/1e9, S41transph);
title('Phase');
xlabel('Frequency (GHz)');
%% S41Spec scan with PNAX
pnax.SetS41SpecParams();
% Phase trace
pnax.S41specparams.trace = 8;
pnax.S41specparams.format = 'UPH';
pnax.SetS41SpecParams();
% Read data
pause(1);
pnax.SetActiveTrace(7);
S41specamp = pnax.Read();
pnax.SetActiveTrace(8);
S41specph = pnax.Read();
freqvector = pnax.GetAxis();
figure(2);
subplot(2,1,1);
plot(freqvector/1e9, S41specamp);
title('Amplitude');
subplot(2,1,2);
plot(freqvector/1e9, S41specph);
title('Phase');
xlabel('Spec frequency (GHz)');

