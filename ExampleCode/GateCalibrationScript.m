%% Add intrument class definitions and initialize instruments
repopath = 'F:\Documents\GitHub\HouckLabMeasurementCode\';
addpath(repopath);
run([repopath, '\instruments_initialize.m']);
clear('repopath');
%% Sync pulsegen and pulsegen2
pulsegen2.SyncWith(pulsegen1);
%% Create objects
params = measlib.QPulseMeas.Params();
instr = measlib.QPulseMeas.Instr();
GateMeas = measlib.GateCalib();
%% Set up parameters
params.driveFreq = 4.7665e9;
params.drivePower = 8.5;
params.measFreq = 10.1653e9;
params.measPower = -5;
params.intFreq = 2e6;
params.loPower = 11;
params.measDuration = 6e-6;
params.numAvg = 65536;
params.trigPeriod = 40e-6;
params.cardDelay = 1e-6;

GateMeas.params = params;
%% Set up instruments
% If you name the instrument differently, change the object names accordingly
instr.qpulsegen = pulsegen1;
instr.mpulsegen = pulsegen2;
instr.rfgen = rfgen;
instr.specgen = specgen;
instr.logen = logen;
instr.digitizer = card;
instr.triggen = triggen;

GateMeas.instr = instr;
%% Set up gate array: (X90)^(2n+1)
sigma = 10e-9;
maxNum = 81;
X90 = pulselib.singleGate('X90');
X90.sigma = sigma;
X90.amplitude = 0.241;
Id = pulselib.singleGate('Identity');
clear('gateArray');
gateArray((maxNum+1)/2, maxNum) = Id;
for row = 1:(maxNum+1)/2
    for col = 1:maxNum-row*2+1
        gateArray(row, col) = Id;
    end
    for col = maxNum-(row-1)*2:maxNum
        gateArray(row, col) = X90;
    end
end
GateMeas.qPulse = gateArray;
%% Run experiment
GateMeas.params.driveFreq = 4.7665e9;
GateMeas.params.trigPeriod = 125e-6;
GateMeas.run();
GateMeas.data.tRange = [0.5e-6, 6.5e-6];
GateMeas.plotData();