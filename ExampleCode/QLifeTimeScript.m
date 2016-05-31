%% Add intrument class definitions and initialize instruments
repopath = 'F:\Documents\GitHub\HouckLabMeasurementCode\';
addpath(repopath);
run([repopath, '\instruments_initialize.m']);
clear('repopath');
%% Sync pulsegen and pulsegen2
pulsegen2.SyncWith(pulsegen1);
%% Create objects
params = measlib.QLifeTime.Params();
instr = measlib.QPulseMeas.Instr();
RabiMeas = measlib.Rabi();
T1Meas = measlib.T1();
RamseyMeas = measlib.Ramsey();
EchoMeas = measlib.Echo();
%% Set up parameters
params.driveSigma = 10e-9;
params.driveFreq = 4.7665e9;
params.drivePower = 8.5;
params.measFreq = 10.1653e9;
params.measPower = -5;
params.intFreq = 2e6;
params.loPower = 11;
params.measDuration = 6e-6;
params.tStep = 0.05e-6;
params.numSteps = 101;
params.numAvg = 65536;
params.trigPeriod = 40e-6;
params.cardDelay = 1e-6;

RabiMeas.params = params;
T1Meas.params = params;
RamseyMeas.params = params;
EchoMeas.params = params;
%% Set up instruments
% If you name the instrument differently, change the object names accordingly
instr.qpulsegen = pulsegen1;
instr.mpulsegen = pulsegen2;
instr.rfgen = rfgen;
instr.specgen = specgen;
instr.logen = logen;
instr.digitizer = card;
instr.triggen = triggen;

RabiMeas.instr = instr;
T1Meas.instr = instr;
RamseyMeas.instr = instr;
EchoMeas.instr = instr;
%% Rabi measurement
RabiMeas.params.trigPeriod = 20e-6;
RabiMeas.run();
RabiMeas.data.tRange = [0.5e-6, 6.5e-6];
RabiMeas.fitData();
%% T1 measurement
T1Meas.params.tStep = 1.5e-6;
T1Meas.params.trigPeriod = 170e-6;
T1Meas.run();
T1Meas.data.tRange = [0.5e-6, 6.5e-6];
T1Meas.fitData();
%% Ramsey measurement
RamseyMeas.params.tStep = 0.2e-6;
RamseyMeas.params.trigPeriod = 60e-6;
RamseyMeas.params.driveFreq = 4.7665e9;
RamseyMeas.run();
RamseyMeas.data.tRange = [0.5e-6, 6.5e-6];
RamseyMeas.fitData();
%% Echo measurement
EchoMeas.params.tStep = 1e-6;
EchoMeas.params.trigPeriod = 160e-6;
EchoMeas.params.driveFreq = 4.7665e9;
EchoMeas.run();
EchoMeas.data.tRange = [0.5e-6, 6.5e-6];
EchoMeas.fitData();