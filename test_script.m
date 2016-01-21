%% Test script for the new instrument programming style

% Initialize instruments
path = 'C:\Users\Gidney\Desktop\Immaculate Sweep\GengyanCode\';
run([path, 'instruments_initialize.m']);

%% Set yoko voltage
yoko.rampstep = 0.002;
yoko.rampinterval = 0.01;
yoko.voltage = 0;
yoko.SetVoltage();
%% Transmission scan with PNAX
transparams.start = 6.25087e9;
transparams.stop = 6.26087e9;
transparams.points = 3001;
transparams.power = -60;
transparams.averages = 65536;
transparams.ifbandwidth = 3e3;

pnax.transparams = transparams;
pnax.SetTransParams();
pause(10);
trans = pnax.Read();
freqvector = pnax.GetAxis();
figure(1);
plot(freqvector/1e9, trans);
xlabel('Frequency (GHz)');
ylabel('Transmission (GHz)');
%% Spec scan with PNAX
specparams.start = 8.42e9;
specparams.stop = 8.44e9;
specparams.points = 2001;
specparams.power = -40;
specparams.averages = 65536;
specparams.ifbandwidth = 3e3;
specparams.cwfreq = 6.2558e9;
specparams.cwpower = -55;

pnax.specparams = specparams;
pnax.SetSpecParams();
pause(10);
spec = pnax.Read();
freqvector = pnax.GetAxis();
figure(2);
plot(freqvector/1e9, spec);
xlabel('Spec frequency (GHz)');
ylabel('Transmission (GHz)');
%% Test AWG
taxis = 0:0.8e-9:15e-6;
% Sin wave for channel 1
waveform1 = sin(2*pi*1e6*taxis).*(taxis <= 10e-6);
% Gaussian pulse for channel 2
waveform2 = exp(-(taxis-5e-6).^2/(2*0.5e-6^2));
% waveform2 = exp(-(taxis-5e-6).^2/(2*0.1e-6^2)) + exp(-(taxis-6e-6).^2/(2*0.1e-6^2));
pulsegen.timeaxis = taxis;
pulsegen.waveform1 = waveform1;
pulsegen.waveform2 = waveform2;
pulsegen.SetParams();
%%
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
rfparams.power = -10;
rfparams.intfreq = 2e6;
rfparams.waittime = 0.2;

test_function(rfparams);

%% Finalize instruments
run('instruments_finalize.m');