function [waveform1,waveform2]=SeqTest(sampling_rate,sigma,pulse_freq)

% time in units of ns
t_delay=0.2e3;    % delay time from trigger BEFORE gaussian starts
t_waveform=2*t_delay;
t=0:1/sampling_rate:(t_waveform-1/sampling_rate); % time vector
pulse_amp = 32000;

waveform =@(t) 0.5*pulse_amp*exp(-(t-t_delay).^2/(2*sigma^2)) ...
            .*cos(2*pi*pulse_freq*t) ...
            .*((t >= t_delay-2*sigma) & (t <= t_delay+2*sigma));

t1=t(t>=0 & t<t_delay);
t2=t(t>=t_delay);

waveform1=waveform(t1);
waveform2=waveform(t2);
        



figure();plot(t1,waveform1,'b',t2,waveform2,'r')
legend('Gaussian pulse 1st half','Gaussian pulse 2nd half')
ylim([-pulse_amp pulse_amp])

end