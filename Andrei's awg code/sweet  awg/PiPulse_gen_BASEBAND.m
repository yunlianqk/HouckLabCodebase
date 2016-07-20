function [waveform1,waveform2]=PiPulse_genV2(sampling_rate,sigma,t_meas)

% time in units of ns
t_waveform=2e3; % total time length of waveform vector
t_delay=0.5e3;    % delay time from trigger BEFORE gaussian starts
t_wait4meas=0;
t=0:1/sampling_rate:(t_waveform-1/sampling_rate); % time vector

pulse_amp = 32000;
amp_meas = 10000;
amp_marker=10000;

waveform1 = 0.5*pulse_amp*exp(-(t-t_delay).^2/(2*sigma^2)) ...
            .*((t >= t_delay-4*sigma) & (t <= t_delay+4*sigma));


waveform2 = amp_meas ...
            .*((t >= t_delay+8*sigma+t_wait4meas) & ...
               (t <= t_delay+8*sigma+t_wait4meas+t_meas));

figure();plot(t,waveform1,'b',t,waveform2,'r')
legend('Gaussian pulse','Measurement Pulse')
ylim([-pulse_amp pulse_amp])

end