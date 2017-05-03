%% Add class definition files to PATH
run(['..', filesep(), 'setpath.m']);
%% Open card
address1 = 'PXI50::15::0::INSTR'; % PXI address
pulsegen1 = M9330AWG(address1);
address2 = 'PXI48::14::0::INSTR';
pulsegen2 = M9330AWG(address2);
clear('address1', 'address2');
%% Synchronize two awg modules
pulsegen2.SyncWith(pulsegen1);
%% Set parameters
% Time axis: 0.8 ns sampling interval, 30 us total length
taxis = 0:0.8e-9:30e-6;
pulsegen1.timeaxis = taxis;
% Channel 1: 1 MHz sine wave between 0 and 10 us
pulsegen1.waveform1 = sin(2*pi*1e6*taxis).*(taxis <= 10e-6);
% Channel 2: Two Gaussian pulses with sigma = 100 ns, center = 5 us and 6 us
% A window of 8*sigma is used to enforce the pulse width
sigma = 100e-9;
ctr1 = 5e-6;
ctr2 = 6e-6;
pulsegen1.waveform2 = exp(-(taxis-ctr1).^2/(2*sigma^2)) ...
                     .*(taxis >= ctr1-4*sigma & taxis <= ctr1+4*sigma) ...
                   + 0.5*exp(-(taxis-ctr2).^2/(2*sigma^2)) ...
                     .*(taxis >= ctr2-4*sigma & taxis <= ctr2+4*sigma);

%% Generate pulses
pulsegen1.Generate();

% Plot waveforms and markers
figure(1);
subplot(2, 1, 1);
hold off;
plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform1);
hold on;
plot(pulsegen1.timeaxis/1e-6, pulsegen1.marker2, 'r');
title('Channel 1');
legend('Waveform', 'Marker');
subplot(2, 1, 2);
hold off;
plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform2/max(abs(pulsegen1.waveform2)));
hold on;
plot(pulsegen1.timeaxis/1e-6, pulsegen1.marker4, 'r');
xlabel('Time (\mus)');
title('Channel 2');
