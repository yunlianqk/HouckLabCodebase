path = 'C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\';
addpath(genpath(path));
run('C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\instruments_initialize.m');
set(0,'DefaultFigureWindowStyle','docked')
pulsegen2.SyncWith(pulsegen1);
%%
params = measlib.QPulseMeas.Params();
instr = measlib.QPulseMeas.Instr();
GateMeas = measlib.GateCalib();
% Set up parameters
params.driveFreq = 9.2830e+09;
params.drivePower = -6;
params.measFreq = 7.664e9;
params.measPower = -20;
params.intFreq = 0;
params.loPower = 11;
params.measDuration = 1e-6;
params.numAvg = 65536;
params.trigPeriod = 40e-6;
params.cardDelay = 0e-6;

GateMeas.params = params;
% Set up instruments
% If you name the instrument differently, change the object names accordingly
instr.qpulsegen = pulsegen1;
instr.mpulsegen = pulsegen2;
instr.rfgen = rfgen;
instr.specgen = specgen;
instr.logen = logen;
instr.digitizer = card;
instr.triggen = triggen;

GateMeas.instr = instr;

%% Assume X90 and Y90 are cailbrated 
clear gateArray
%prepare the qubit from ground state to 
gateArray(1:3,1) = X90;
gateArray(1,2) = Id;
gateArray(2,2) = Y90;
gateArray(3,2) = X90;

%%

% Run experiment
GateMeas.qPulse = gateArray;
GateMeas.params.trigPeriod = 15e-6;
GateMeas.run();
GateMeas.data.tRange = [0.5e-6, 1.5e-6];
GateMeas.plotData();

I_data = GateMeas.data.intdataI;
Q_data = GateMeas.data.intdataQ;
