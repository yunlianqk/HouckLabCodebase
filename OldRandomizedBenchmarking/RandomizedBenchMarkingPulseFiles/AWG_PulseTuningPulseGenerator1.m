function [ ] = AWG_PulseTuningPulseGenerator1( AWGHandle, pulseamp, pulsequad, dragamp, num_gate)

%this function corrects X90p and X90m amp errors
sampling_rate = 1.25;%in unit of GHz, this is the internal sampling rate
amp = 32000;
amp_meas = 10000;
t_wait_real = 20000;
t_cycle_real = 40000;
t_meas_real = 4000;
t_wait4meas_real = 32/5;
%t_wait4meas_real = 0;
sigma_real = 2;
secpulsewait = 4; % in nanoseconds
markbuff = 64+16; % in nanoseconds
anchor_step = 10;

t_wait = t_wait_real*sampling_rate;%this number should divide 8
t_cycle = t_cycle_real*sampling_rate;
t_meas = t_meas_real*sampling_rate;
sigma = sigma_real*sampling_rate;%the sampling rate is 0.8ns
t_wait4meas = t_wait4meas_real*sampling_rate;
t_secpulsewait = secpulsewait*sampling_rate;
t_markbuff = markbuff*sampling_rate;
anchor_step = anchor_step*sampling_rate;

% create qubit and drag pulse
gausspulse = exp(-(-2*sigma:1:2*sigma).^2/(2*sigma.^2));
%dragpulse = diff(gausspulse);
dragpulse = (-2*sigma:1:2*sigma)./(sigma^2).*exp(-(-2*sigma:1:2*sigma).^2/(2*sigma.^2));
% normalize pulses to [0 1];
%gausspulse = gausspulse/max(gausspulse);
dragpulse = dragpulse/max(dragpulse);
% multiply drag pulse by "Beta"
dragpulse = dragamp*dragpulse;

% waveform1 = zeros(1,t_wait);
% waveform3 = zeros(1,t_wait);

if pulsequad == 0
    % rotation should be around y axis
    waveform1 = [zeros(1,t_wait-(2*num_gate+1)*length(gausspulse)-2*num_gate*t_secpulsewait), pulseamp*amp*gausspulse];
    waveform3 = [zeros(1,t_wait-(2*num_gate+1)*length(gausspulse)-2*num_gate*t_secpulsewait), pulseamp*amp*dragpulse];
    if num_gate ~= 0
        for counter1=1:num_gate
            waveform1 = [waveform1, zeros(1,t_secpulsewait), pulseamp*amp*gausspulse, zeros(1,t_secpulsewait), pulseamp*amp*gausspulse];
            waveform3 = [waveform3, zeros(1,t_secpulsewait), pulseamp*amp*dragpulse, zeros(1,t_secpulsewait), pulseamp*amp*dragpulse];
        end
    end
else
    waveform1 = [zeros(1,t_wait-(2*num_gate+1)*length(gausspulse)-2*num_gate*t_secpulsewait), pulseamp*amp*dragpulse];
    waveform3 = [zeros(1,t_wait-(2*num_gate+1)*length(gausspulse)-2*num_gate*t_secpulsewait), pulseamp*amp*gausspulse];
    % rotation should be around x axis
    if num_gate ~= 0
        for counter1=1:num_gate
            waveform1 = [waveform1, zeros(1,t_secpulsewait), pulseamp*amp*dragpulse, zeros(1,t_secpulsewait), pulseamp*amp*dragpulse];
            waveform3 = [waveform3, zeros(1,t_secpulsewait), pulseamp*amp*gausspulse, zeros(1,t_secpulsewait), pulseamp*amp*gausspulse];
        end
    end
end

waveform2 = [zeros(1,t_wait+t_wait4meas), amp_meas*ones(1,t_meas), zeros(1,t_cycle-t_meas-t_wait4meas-t_wait)];

marker1_length = floor(length(gausspulse)/8)+8;
marker1 = zeros(t_wait-t_markbuff-(2*num_gate+1)*length(gausspulse)-(2*num_gate)*t_secpulsewait,1);
marker1 = [marker1; 10000*ones(t_markbuff,1); 10000*ones((2*num_gate+1)*length(gausspulse)+(2*num_gate)*t_secpulsewait,1); 10000*ones(t_markbuff/2-8,1)];
marker1 = [marker1; zeros(length(waveform2)-length(marker1),1)];
marker1 = marker1(1:8:end);

marker2 = [zeros(t_wait/8-4,1); 10000*ones(t_meas/8,1);zeros(t_cycle/8-t_meas/8-t_wait/8+4,1)];
%marker2 = zeros(t_wait,1);
%marker2 = [marker2; zeros((2*num_gate+1)*length(gausspulse)+t_wait4meas+(2*num_gate),1); ]

waveform1 = [waveform1, zeros(1,length(waveform2)-length(waveform1))];
waveform3 = [waveform3, zeros(1,length(waveform2)-length(waveform3))];
emptywaveform = zeros(1,length(waveform2));
emptymarker = zeros(t_cycle/8,1);

ArbWave2Channel(AWGHandle.driver2,emptywaveform,emptymarker,waveform2,marker2,2);
ArbWave2Channel(AWGHandle.driver1,waveform1,marker1,waveform3,marker1,2);


end