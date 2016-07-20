function [ waveform ] = RectangPulse( sampling_rate,readParam,plt )
t_waveform=readParam.delay_before ...
            +readParam.length ...
            +readParam.delay_after;
        

t=0:1/sampling_rate:(t_waveform-1/sampling_rate);
read_amp=readParam.amp;
waveform=read_amp*cos(2*pi*readParam.freq*t) ...
            .*((t >= readParam.delay_before) & ...
               (t <= readParam.delay_before+readParam.length));            

if plt==1
    figure()
    plot(t,waveform)
    ylim([-readParam.amp readParam.amp]) 
end
end

