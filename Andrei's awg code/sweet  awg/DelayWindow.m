function [ waveform ] = DelayWindow( sampling_rate,t_delay )
t=0:1/sampling_rate:(t_delay-1/sampling_rate);
waveform=0*((t >= 0) & (t <= t_delay));            
end

