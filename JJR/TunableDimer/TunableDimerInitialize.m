% Add tunable dimer folder to path
cd('C:\Users\HouckLab\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')
path = pwd; addpath(genpath(path));
cd('C:\Users\HouckLab\Documents\GitHub\HouckLabMeasurementCode')
instruments_initialize_oxford
dataDirectory = 'C:/Data/';
clear('path');
% %%
pnax.DeleteAll();

% %% initialize channel 1 - transmission
% Trace 1 is S21 and Trace 2 is S41.  
transS21 = paramlib.pnax.trans();
pnax.SetParams(transS21);
transS41 = transS21;
transS41.trace = 2;
transS41.meastype = 'S41';
pnax.SetParams(transS41);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();
pause(1)
ftrans = pnax.ReadAxis();
pnax.SetActiveTrace(1);
[data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
pnax.SetActiveTrace(2);
[data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
plot(ftrans,data_transS21A,'b',ftrans,data_transS41A,'r');
subplot(2,1,2);
plot(ftrans,data_transS21P,'b',ftrans,data_transS41P,'r');

% %% initialize channel 2 - spec
% Trace 3 is S21 and Trace 4 is S41.  
specS21 = paramlib.pnax.spec();
pnax.SetParams(specS21);
specS41 = specS21;
specS41.trace = 4;
specS41.meastype = 'S41';
pnax.SetParams(specS41);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();
pause(1)
fspec = pnax.ReadAxis();
pnax.SetActiveTrace(3);
[data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();
pnax.SetActiveTrace(4);
[data_specS41A data_specS41P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
plot(fspec,data_specS21A,'b',fspec,data_specS41A,'r');
subplot(2,1,2);
plot(fspec,data_specS21P,'b',fspec,data_specS41P,'r');


