function [waveform]=PiPulse_genV2(sampling_rate,sigma,t_meas,pulse_freq,meas_freq)

% time in units of ns
t_waveform=20e-6; % total time length of waveform vector
t_delay=2e-6;    % delay time from trigger BEFORE gaussian starts
t_wait4meas=1e-6;
t=0:1/sampling_rate:(t_waveform-1/sampling_rate); % time vector

pulse_amp = 1;
amp_meas = 0;

waveform = pulse_amp*exp(-(t-t_delay).^2/(2*sigma^2)) ...
            .*cos(2*pi*pulse_freq*t) ...
            .*((t >= t_delay-2*sigma) & (t <= t_delay+2*sigma)) ...
            + amp_meas*cos(2*pi*meas_freq*t) ...
            .*((t >= t_delay+2*sigma+t_wait4meas) & ...
               (t <= t_delay+2*sigma+t_wait4meas+t_meas));

figure();plot(t,waveform)
ylim([-pulse_amp pulse_amp])

end