function [waveform]=SinglePulse(sampling_rate,pulseParam,plt)

t_waveform=pulseParam.delay_before ...
           +4*pulseParam.sigma ...
           +pulseParam.delay_after;
       
t=0:1/sampling_rate:(t_waveform-1/sampling_rate);
t_center=pulseParam.delay_before+2*pulseParam.sigma;

pulse_amp=pulseParam.amp;
waveform = pulse_amp*exp(-(t-t_center).^2/(2*pulseParam.sigma^2)) ...
            .*cos(2*pi*pulseParam.freq*t) ...
            .*((t >= t_center-2*pulseParam.sigma) & (t <= t_center+2*pulseParam.sigma));
if plt==1
    figure()
    plot(t,waveform)
    ylim([-pulseParam.amp pulseParam.amp]) 
end
end