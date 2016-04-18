function [ ] = AWG_ArbGaussianPulseGenerator( AWGHandle, pulseamp, pulsequad, dragamp ,anchor_value)
%UNTITLED Summary of this function goes here
%   pulseamp should be +- 1 or +-.5, determines pi pulse or pi/2 pulse
%   pulsequad should be 0 (X axis) or 1 (Y axis)
 
sampling_rate = 1.25;%in unit of GHz, this is the internal sampling rate
amp = 32000;
amp_meas = 10000;
t_wait_real = 20000;
t_cycle_real = 40000;
t_meas_real = 4000;
t_wait4meas_real = 32/5;
%t_wait4meas_real = 0;
sigma_real = 2; % has been changed from 2...SRI
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
dragpulse = (-2*sigma:1:2*sigma)./(sigma^2).*exp(-(-2*sigma:1:2*sigma).^2/(2*sigma.^2));
% normalize pulses to [0 1];
%gausspulse = gausspulse/max(gausspulse);
dragpulse = dragpulse/max(dragpulse);
% multiply drag pulse by "Beta"
dragpulse = dragamp*dragpulse;


%sharp turn on cavity readout pulse
meas_waveform = ArbMeasWaveformGenerator([0,anchor_value], anchor_step, t_meas);  
waveform2 = [zeros(1,t_wait+2*length(gausspulse)+t_wait4meas+t_secpulsewait), amp_meas*meas_waveform,zeros(1,t_cycle-t_meas-t_wait4meas-t_wait-2*length(gausspulse)-t_secpulsewait)];
    
%marker2 = [zeros(t_wait/8,1); 10000*ones(t_meas/8,1);zeros(t_cycle/8-t_meas/8-t_wait/8,1)];
%marker2 = [marker2; zeros(t_cycle_real/8 - length(marker2),1)];

% create zeros leading to qubit pulse
waveform1 = zeros(1,t_wait);
waveform3 = zeros(1,t_wait);

% defining first qubit pulse
if pulsequad(1) == 0
    % rotation should be around x axis
    waveform1 = [waveform1, pulseamp(1)*amp*gausspulse];
    waveform3 = [waveform3, pulseamp(1)*amp*dragpulse];
else
    % rotation should be around y axis
    waveform1 = [waveform1, pulseamp(1)*amp*dragpulse];
    waveform3 = [waveform3, pulseamp(1)*amp*gausspulse];
end

% defining second qubit pulse
if pulsequad(2) == 0
    % rotation should be around x axis
    waveform1 = [waveform1, zeros(1,t_secpulsewait), pulseamp(2)*amp*gausspulse];
    waveform3 = [waveform3, zeros(1,t_secpulsewait), pulseamp(2)*amp*dragpulse];
else
    % rotation should be around y axis
    waveform1 = [waveform1, zeros(1,t_secpulsewait), pulseamp(2)*amp*dragpulse];
    waveform3 = [waveform3, zeros(1,t_secpulsewait), pulseamp(2)*amp*gausspulse];
end

marker1_length = floor(length(gausspulse)/8)+8;
% marker1 = [zeros(t_wait/8-6,1);ones(2*marker1_length,1)*10000;zeros(t_cycle/8-t_wait/8-2*marker1_length+6,1)];

marker1 = zeros(t_wait-t_markbuff,1);
marker1 = [marker1; 10000*ones(t_markbuff,1); 10000*ones(2*length(gausspulse) + t_secpulsewait ,1); 10000*ones(t_markbuff/2-8,1)];
marker1 = [marker1; zeros(length(waveform2)-length(marker1),1)];
marker1 = marker1(1:8:end);

marker2 = [zeros(t_wait/8-4,1); 10000*ones(t_meas/8,1);zeros(t_cycle/8-t_meas/8-t_wait/8+4,1)];

waveform1 = [waveform1, zeros(1,length(waveform2)-length(waveform1))];
waveform3 = [waveform3, zeros(1,length(waveform2)-length(waveform3))];
emptywaveform = zeros(1,length(waveform2));
emptymarker = zeros(t_cycle/8,1);

ArbWave2Channel(AWGHandle.driver2,emptywaveform,emptymarker,waveform2,marker2,2);
ArbWave2Channel(AWGHandle.driver1,waveform1,marker1,waveform3,marker1,2);
    

end

