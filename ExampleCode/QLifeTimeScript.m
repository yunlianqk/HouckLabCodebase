%% Add intrument class definitions and initialize instruments
repopath = 'C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\';
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
params.driveSigma = 5e-9;
params.driveFreq = 9.278e9 ;
params.drivePower =-10;
params.measFreq = 7.664e9;
params.measPower = -20;
params.intFreq = 0; %detunning
params.loPower = 11;
params.measDuration = 1e-6;
params.tStep = 0.01e-6;
params.numSteps = 41;
params.numAvg = 65536;
params.trigPeriod = 40e-6;
params.cardDelay = 0e-6;

GateMeas.params = params;
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
RabiMeas.data.tRange = [0.5e-6, 1.5e-6];
result = RabiMeas.fitData();
%%
params.drivePower = params.drivePower - 20*log10(result/pi);
RabiMeas.params = params;
RabiMeas.params.trigPeriod = 20e-6;
RabiMeas.run();
RabiMeas.data.tRange = [0.5e-6, 1.5e-6];
result = RabiMeas.fitData();
%% T1 measurement
T1Meas.params.tStep = 0.01e-6;
T1Meas.params.trigPeriod = 15e-6;
T1Meas.run();
%%
T1Meas.data.tRange = [0.5e-6, 1.8e-6];
T1Meas.fitData();
%% Ramsey measurement
params.numSteps = 101;
RamseyMeas.params = params;

RamseyMeas.params.driveFreq = 9.278e9;

RamseyMeas.params.tStep = 0.01e-6;
RamseyMeas.params.trigPeriod = 25e-6;
RamseyMeas.run();
RamseyMeas.data.tRange = [0.5e-6, 1.5e-6];
RamseyMeas.fitData();
%% FFT find frequency detunning
temp = RamseyMeas.data.intdataI;
T = RamseyMeas.params.tStep;
L = params.numSteps;
% t = 0:T:1e-6;
Fs = 1/T;
f = Fs*(0:(L/2))/L;
Y = fft(temp);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
figure(112)
plot(f/1e6,P1)
title('FFT of ramsey')
xlabel('f (MHz)')
ylabel('Amp')
%% Peak detect
Max = max(P1);
[~, loc] = findpeaks(P1,'MinPeakHeight', 0.1*Max)
f(loc)

%% Ramsey measurement
params.numSteps = 101;
RamseyMeas.params = params;

RamseyMeas.params.driveFreq = 9.278e9 - f(loc);

RamseyMeas.params.tStep = 0.01e-6;
RamseyMeas.params.trigPeriod = 25e-6;
RamseyMeas.run();
RamseyMeas.data.tRange = [0.5e-6, 1.5e-6];
RamseyMeas.fitData();
%%
  temp_I = RamseyMeas.data.intdataI;
    temp_Q = RamseyMeas.data.intdataQ;

    T = RamseyMeas.params.tStep;
    L = params.numSteps;
    % t = 0:T:1e-6;
    Fs = 1/T;
    f = Fs*(0:(L/2))/L;
    Y_I = fft(temp_I);
    Y_Q = fft(temp_Q);

    P2_I = abs(Y_I/L);   
    P2_Q = abs(Y_Q/L);

    P1_I = P2_I(1:L/2+1);
    P1_Q = P2_Q(1:L/2+1);
    P1_I(2:end-1) = 2*P1_I(2:end-1);
    P1_Q(2:end-1) = 2*P1_Q(2:end-1);

    figure(112)
    subplot(2,1,1)
    plot(f/1e6,P1_I)
    title('FFT of Ramsey  I')
    xlabel('f (MHz)')
    ylabel('Amp')
    
    subplot(2,1,2)
    plot(f/1e6,P1_Q)
    title('FFT of Ramsey Q')
    xlabel('f (MHz)')
    ylabel('Amp')
%% Echo measurement
EchoMeas.params.tStep = 0.01e-6;
EchoMeas.params.trigPeriod = 10e-6;
EchoMeas.params.driveFreq = params.driveFreq -2e6;
EchoMeas.run();
%%
EchoMeas.data.tRange = [0.5e-6, 1.6e-6];
EchoMeas.fitData();