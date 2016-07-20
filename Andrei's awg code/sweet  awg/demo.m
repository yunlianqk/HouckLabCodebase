%%
% Add iqtools folder to path
addpath('C:\Program Files (x86)\Keysight\M8195\Examples\MATLAB\iqtools')
addpath('C:\Users\newforce\Documents\MATLAB\Immaculate Sweep\Andrei code\sweet  awg')
%%
iqmain()
% Configure awg manually M8195_1ch Triggered

%% Clear previous sequence
clear seq
iqseq('delete', [], 'keepOpen', 1);

%% Download segments
%define sampling rate
sampling_rate=32e9;

% load pulse param
pulseParam=loadPulseParam(20e-9,5e9,2,8e-9,8e-9);
seqsigma=(20:4:60)*1e-9;

for i=1:11
    pulseParam.sigma=seqsigma(i);
    waveform=SinglePulse(sampling_rate,pulseParam,0);
    % each segment has increasing sigma
    iqdownload(waveform, sampling_rate,'channelMapping',[1 0;0 0;0 0;0 0], 'segmentNumber', i, 'keepOpen', 1, 'run', 0,'normalize',1);
end

%% Setup sequence
for i=1:11
    seq(i).segmentNumber=i;
    seq(i).segmentLoops=1;
    seq(i).markerEnable=true;
    seq(i).segmentAdvance='Auto';
end
%% START SEQ
iqseq('define', seq, 'keepOpen', 1, 'run', 1);
%% STOP SEQ
iqseq('define', seq, 'keepOpen', 1, 'run', 0);

%% T1 sequence
% Define+Download rectangular readout pulse
readParam=loadReadParam(4e-6,7e9,0.5,8e-9,8e-9);
readout=RectangPulse(sampling_rate,readParam,0);
iqdownload(readout, sampling_rate,'channelMapping',[1 0;0 0;0 0;0 0], 'segmentNumber', 3, 'keepOpen', 1, 'run', 1);
%%
% Define+Download Gaussian pulse
pulseParam=loadPulseParam(50e-9,5e9,1,8e-9,8e-9);
pulse=SinglePulse(sampling_rate,pulseParam,0);
iqdownload(pulse, sampling_rate,'channelMapping',[1 0;0 0;0 0;0 0], 'segmentNumber', 2, 'keepOpen', 1, 'run', 1);
%%
% Delay
delay_init=DelayWindow(64e9,10e-6);
iqdownload(delay_init, 64e9,'channelMapping',[1 0;0 0;0 0;0 0], 'segmentNumber', 1, 'keepOpen', 1, 'run', 1);

%%
sampling_rate=64e9;
sigma=50e-9;
t_meas=5e-6;
pulse_freq=5e9;
meas_freq=7e9;
waveform=PiPulse_genV2(sampling_rate,sigma,t_meas,pulse_freq,meas_freq);
iqdownload(waveform, sampling_rate,'channelMapping',[1 0;0 0;0 0;0 0], 'segmentNumber', 1, 'keepOpen', 1, 'run', 1);



















