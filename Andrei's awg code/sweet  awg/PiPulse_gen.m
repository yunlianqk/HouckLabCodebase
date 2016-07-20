function [waveform1,waveform2] = PiPulse_gen(sampling_rate,sigma,t_meas,pulse_freq,meas_freq)

pulse_amp = 32000;
amp_meas = 10000;
amp_marker=10000;

% Time units are in nano-sec
t_delay_real=1e3;  % time gaussian starts AFTER trigger
t_wait4meas_real=8; % time measurement starts AFTER gaussian
t_cycle_real=4e3;  % total time of waveform

% check that these numbers will work nicely when generating the markers
assert(mod(t_delay_real,8)==0,'t_wait_real is not divisible by 8');
assert(mod(t_cycle_real,8)==0,'t_cycle_real is not divisible by 8');

% convert times into # of samples for each segement
t_delay=t_delay_real*sampling_rate;
t_cycle=t_cycle_real*sampling_rate;
t_meas=t_meas*sampling_rate;
sigma=sigma*sampling_rate;
t_wait4meas=t_wait4meas_real*sampling_rate;

%==== Generate waveforms =====
% Waveform 1 - Gaussian pulse
gaussian = 0.5*pulse_amp*exp(-(-4*sigma:1:4*sigma).^2/(2*sigma.^2));
time=(0:length(gaussian)-1)/sampling_rate;
% add modulation
gaussian=gaussian.*cos(2*pi*pulse_freq*time);
waveform1=[zeros(1,t_delay),gaussian,zeros(1,t_cycle-t_delay-length(gaussian))];
% Waveform 2 - Rectangular measurement pulse
% add modulation
measurement=amp_meas*ones(1,t_meas).*cos(2*pi*meas_freq*(0:t_meas-1)/sampling_rate);
waveform2=[zeros(1,t_delay+length(gaussian)+t_wait4meas),measurement,zeros(1,t_cycle-t_delay-length(gaussian)-t_wait4meas-t_meas)];
% check lengths
assert(length(waveform1)==length(waveform2),'waveform lengths unequal')
%==== Generate markers =====


% Plot waveforms and markers
figure();
t_waveform=(1:length(waveform1))/sampling_rate/1e3;
plot(t_waveform,waveform1,'b',t_waveform,waveform2,'r')
hold on
xlabel('Time (\mu s)');
ylabel('Amplitude')
title('Pulse sequence')



end