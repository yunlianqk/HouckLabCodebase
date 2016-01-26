%% Test script for the new instrument programming style

% Initialize instruments
path = 'C:\Users\Gidney\Desktop\Immaculate Sweep\GengyanCode\';
run([path, 'instruments_initialize.m']);

%% Set yoko voltage
yoko.rampstep = 0.002;
yoko.rampinterval = 0.01;
yoko.voltage = 0;
yoko.SetVoltage();
%% Set triggen generator
triggen.SetPeriod(30e-6);

%% Transmission scan with PNAX
transparams.start = 6.25087e9;
transparams.stop = 6.26087e9;
transparams.points = 3001;
transparams.power = -60;
transparams.averages = 65536;
transparams.ifbandwidth = 3e3;
% Amp trace
transparams.trace = 1;
transparams.meastype = 'S21';
transparams.format = 'MLOG';
pnax.transparams = transparams;
pnax.SetTransParams();
% Phase trace
pnax.transparams.trace = 2;
pnax.transparams.format = 'UPH';
pnax.SetTransParams();
% Read data
pause(5);
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
%% Spec scan with PNAX
specparams.start = 8.42e9;
specparams.stop = 8.44e9;
specparams.points = 2001;
specparams.power = -40;
specparams.averages = 65536;
specparams.ifbandwidth = 3e3;
specparams.cwfreq = 6.2558e9;
specparams.cwpower = -55;
% Amp trace
specparams.trace = 3;
specparams.meastype = 'S21';
specparams.format = 'MLOG';
pnax.specparams = specparams;
pnax.SetSpecParams();
% Phase trace
specparams.trace = 4;
specparams.format = 'UPH';
pnax.specparams = specparams;
pnax.SetSpecParams();
% Read data
pause(5);
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

%% Test AWG
taxis = 0:0.8e-9:30e-6;
% Sin wave for channel 1
waveform1 = 2*sin(2*pi*1e6*taxis).*(taxis <= 10e-6);
% Gaussian pulse for channel 2
% waveform2 = exp(-(taxis-5e-6).^2/(2*0.5e-6^2));
waveform2 = 3*exp(-(taxis-5e-6).^2/(2*0.1e-6^2)) + exp(-(taxis-6e-6).^2/(2*0.1e-6^2));
pulsegen.timeaxis = taxis;
pulsegen.waveform1 = waveform1;
pulsegen.waveform2 = waveform2;
pulsegen.SetParams();
% Plot waveforms
figure(3);
subplot(2,1,1);
hold off;
plot(pulsegen.timeaxis/1e-6, pulsegen.waveform1/max(abs(pulsegen.waveform1)));
hold on;
plot(pulsegen.timeaxis/1e-6, pulsegen.marker1, 'r');
legend('Waveform 1', 'Marker 1');
subplot(2,1,2);
hold off;
plot(pulsegen.timeaxis/1e-6, pulsegen.waveform2/max(abs(pulsegen.waveform2)));
hold on;
plot(pulsegen.timeaxis/1e-6, pulsegen.marker2, 'r');
legend('Waveform 2', 'Marker 2');
xlabel('Time (\mus)');
%% Compatibility with old code
instr.pnax = pnax.instrhandle;
data = read_PNAX(instr);
figure;plot(data);
%% Call functions to do measurement
rfparams.freq = 5e9;
rfparams.power = -20;
rfparams.intfreq = 1e6;
rfparams.waittime = 0.2;

test_function(rfparams);

%% Finalize instruments
run('instruments_finalize.m');