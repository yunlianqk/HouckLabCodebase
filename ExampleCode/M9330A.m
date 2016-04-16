%% Add class definition files to PATH
repopath = 'F:\Documents\GitHub\HouckLabMeasurementCode\';
addpath(genpath(repopath));
clear(repopath);
%% Open card
address = 'PXI50::15::0::INSTR'; % PXI address
pulsegen = M9330AWG(address);
%% Set parameters

% Time axis: 0.8 ns sampling interval, 30 ?s total length
taxis = 0:0.8e-9:30e-6;
pulsegen.timeaxis = taxis;
% Channel 1: 1 MHz sine wave between 0 and 10 ?s
pulsegen.waveform1 = sin(2*pi*1e6*taxis).*(taxis <= 10e-6);
% Channel 2: Two Gaussian pulses with ? = 100 ns, center = 5 ?s and 6 ?s
% A window of 8? is used to enforce the pulse width
sigma = 100e-9;
ctr1 = 5e-6;
ctr2 = 6e-6;
pulsegen.waveform2 = exp(-(taxis-ctr1).^2/(2*sigma^2)) ...
                     .*(taxis >= ctr1-4*sigma & taxis <= ctr1+4*sigma) ...
                   + 0.5*exp(-(taxis-ctr2).^2/(2*sigma^2)) ...
                     .*(taxis >= ctr2-4*sigma & taxis <= ctr2+4*sigma);
%% Generate pulses
pulsegen.Generate();

% Plot waveforms and markers
figure(1);
subplot(2,1,1);
hold off;
plot(pulsegen.timeaxis/1e-6, pulsegen.waveform1);
hold on;
plot(pulsegen.timeaxis/1e-6, pulsegen.marker1, 'r');
title('Channel 1');
legend('Waveform', 'Marker');
subplot(2,1,2);
hold off;
plot(pulsegen.timeaxis/1e-6, pulsegen.waveform2/max(abs(pulsegen.waveform2)));
hold on;
plot(pulsegen.timeaxis/1e-6, pulsegen.marker2, 'r');
xlabel('Time (\mus)');
title('Channel 2');