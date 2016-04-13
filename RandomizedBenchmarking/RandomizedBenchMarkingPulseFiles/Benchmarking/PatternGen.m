function [] = PatternGen(AWGHandle, PulseSequence)

sampling_rate = 1.25;%in unit of GHz, this is the internal sampling rate
amp = 32000;
amp_meas = 10000;
t_wait_real = 20000;  %?????
t_cycle_real = 40000;  %????
t_meas_real = 4000;
t_wait4meas_real = 32/5;
%t_wait4meas_real = 0;
sigma_real = 2;
secpulsewait = 8; % in nanoseconds
markbuff = 64+16; % in nanoseconds

t_wait = t_wait_real*sampling_rate;%this number should divide 8
t_cycle = t_cycle_real*sampling_rate;
t_meas = t_meas_real*sampling_rate;
sigma = sigma_real*sampling_rate;%the sampling rate is 0.8ns
t_wait4meas = t_wait4meas_real*sampling_rate;
t_secpulsewait = secpulsewait*sampling_rate;
t_markbuff = markbuff*sampling_rate;


%Parameters for 2ns sigma pulse
X90p = 0.278; X90m = -0.294; X180p = 0.568; X180m = -0.586;
Y90p = 0.294; Y90m = -0.292; Y180p = 0.606; Y180m = -0.606;
dragampx = -0.3;
dragampy = 0.3;
%Parameters for 2ns sigma pulse

% create qubit and drag pulse
gausspulse = exp(-(-2*sigma:1:2*sigma).^2/(2*sigma.^2));
%dragpulse = diff(gausspulse);
dragpulse = (-2*sigma:1:2*sigma)./(sigma^2).*exp(-(-2*sigma:1:2*sigma).^2/(2*sigma.^2));
dragpulse = dragpulse/max(dragpulse);
% multiply drag pulse by "Beta"
dragpulsey = dragampy*dragpulse;
dragpulsex = dragampx*dragpulse;

num_pulse = length(PulseSequence);
waveform1 = zeros(1,t_wait-num_pulse*length(gausspulse)-(num_pulse-1)*t_secpulsewait);
waveform3 = zeros(1,t_wait-num_pulse*length(gausspulse)-(num_pulse-1)*t_secpulsewait);
for counter1 = 1:num_pulse
    if(strcmp(PulseSequence{counter1},'Y90p')==1)
        waveform1 = [waveform1, Y90p*amp*gausspulse, zeros(1,t_secpulsewait)];
        waveform3 = [waveform3, Y90p*amp*dragpulsey, zeros(1,t_secpulsewait)];     
    elseif(strcmp(PulseSequence{counter1},'Y90m')==1)
        waveform1 = [waveform1, Y90m*amp*gausspulse, zeros(1,t_secpulsewait)];
        waveform3 = [waveform3, Y90m*amp*dragpulsey, zeros(1,t_secpulsewait)];
    elseif(strcmp(PulseSequence{counter1},'Yp')==1)
        waveform1 = [waveform1, Y180p*amp*gausspulse, zeros(1,t_secpulsewait)];
        waveform3 = [waveform3, Y180p*amp*dragpulsey, zeros(1,t_secpulsewait)];
    elseif(strcmp(PulseSequence{counter1},'X90p')==1)
        waveform1 = [waveform1, X90p*amp*dragpulsex, zeros(1,t_secpulsewait)];
        waveform3 = [waveform3, X90p*amp*gausspulse, zeros(1,t_secpulsewait)];
    elseif(strcmp(PulseSequence{counter1},'X90m')==1)
        waveform1 = [waveform1, X90m*amp*dragpulsex, zeros(1,t_secpulsewait)];
        waveform3 = [waveform3, X90m*amp*gausspulse, zeros(1,t_secpulsewait)];
    elseif(strcmp(PulseSequence{counter1},'Xp')==1)
        waveform1 = [waveform1, X180p*amp*dragpulsex, zeros(1,t_secpulsewait)];
        waveform3 = [waveform3, X180p*amp*gausspulse, zeros(1,t_secpulsewait)];
    elseif(strcmp(PulseSequence{counter1},'QId')==1)
        waveform1 = [waveform1, zeros(1,length(gausspulse)), zeros(1,t_secpulsewait)];
        waveform3 = [waveform3, zeros(1,length(gausspulse)), zeros(1,t_secpulsewait)];
    end
end

waveform2 = [zeros(1,t_wait+t_wait4meas), amp_meas*ones(1,t_meas), zeros(1,t_cycle-t_meas-t_wait4meas-t_wait)];


%create markers 
%marker1_length = floor(length(gausspulse)/8)+8;
marker1 = zeros(t_wait-t_markbuff-(num_pulse)*length(gausspulse)-(num_pulse-1)*t_secpulsewait,1);
marker1 = [marker1; 10000*ones(t_markbuff,1); 10000*ones(num_pulse*length(gausspulse)+(num_pulse-1)*t_secpulsewait,1); 10000*ones(t_markbuff/2-32,1)];
marker1 = [marker1; zeros(length(waveform2)-length(marker1),1)];
marker1 = marker1(1:8:end);

marker2 = [zeros(t_wait/8-4,1); 10000*ones(t_meas/8,1);zeros(t_cycle/8-t_meas/8-t_wait/8+4,1)];

waveform1 = [waveform1, zeros(1,length(waveform2)-length(waveform1))];
waveform3 = [waveform3, zeros(1,length(waveform2)-length(waveform3))];
emptywaveform = zeros(1,length(waveform2));
emptymarker = zeros(t_cycle/8,1);

ArbWave2Channel(AWGHandle.driver2,emptywaveform,emptymarker,waveform2,marker2,0);
ArbWave2Channel(AWGHandle.driver1,waveform1,marker1,waveform3,marker1,2);























