%%
% Add iqtools folder to path
addpath('C:\Program Files (x86)\Keysight\M8195\Examples\MATLAB\iqtools')
addpath('C:\Users\newforce\Documents\MATLAB\Immaculate Sweep\Andrei code\sweet  awg')
%%
iqmain()
% Configure awg manually M8195_2ch Triggered
%%  define sampling rate
sampling_rate=32e9;
%% Clear previous sequence
clear seq
iqseq('delete', [], 'keepOpen', 1);
%% Define + Download initial delay
% Delay
delayLength=1e-6;
delay_init=DelayWindow(sampling_rate,delayLength);
iqdownload(delay_init, sampling_rate,'channelMapping',[1 0;0 0;0 0;0 0], 'segmentNumber', 1, 'keepOpen', 1, 'run', 0);
%% Define + Download rectangular readout pulse
% Readout parameters
readLength=5e-6;
readFreq=10e9;
readAmp=1;
read_delayBefore=8e-9;
read_delayAfter=8e-9;
readParam=loadReadParam(readLength,readFreq, readAmp, read_delayBefore,read_delayAfter); 
plt=0; % 1=plot, 0=no plot
readout=RectangPulse(sampling_rate,readParam,plt);  % Readout pulse
iqdownload(readout, sampling_rate,'channelMapping',[1 0;0 0;0 0;0 0], 'segmentNumber', 2, 'keepOpen', 1, 'run', 0);
%% Define + Download PiPulse segments with variable delay

% load pulse param
pulseSigma=20e-9;
pulseFreq=4e9;
pulseAmp=1;
pulse_delayTotal=20e-6+8e-9;
pulse_delayAfter=8e-9;
pulse_delayBefore=pulse_delayTotal-pulse_delayAfter;
pulseParam=loadPulseParam(pulseSigma,pulseFreq,pulseAmp,pulse_delayBefore,pulse_delayBefore);

steps=linspace(0,20e-6,21);

for i=1:length(steps)
    pulseParam.delay_after=8e-9+steps(i);
    pulseParam.delay_before=pulse_delayTotal-pulseParam.delay_after;
    waveform=SinglePulse(sampling_rate,pulseParam,0);
    % each segment has increasing delay time to readout
    % segment 1 and 2 are dedicated for initial delay and readout
    % segment 3,4,... used for storring qubit pulses=> i+2
    iqdownload(waveform, sampling_rate,'channelMapping',[1 0;0 0;0 0;0 0], 'segmentNumber', i+2, 'keepOpen', 1, 'run', 0);
end

%% Setup sequence
%  'Auto'= next seg foolows automatically
%  'Conditional'=wait for event(=trigger) before starting next segment (last element in previous seg is played continuously until event is triggered)
seqLength=3*length(steps);

for i=1:seqLength
    switch mod(i,4)
        case 1
            seq(i).segmentNumber=1;
            seq(i).segmentLoops=10;
            seq(i).markerEnable=true;
            seq(i).segmentAdvance='Auto';
        case 2
            seq(i).segmentNumber=(i-rem(i,4))/4+3;
            seq(i).segmentLoops=1;
            seq(i).markerEnable=true;
            seq(i).segmentAdvance='Auto';
        case 3
            seq(i).segmentNumber=2;
            seq(i).segmentLoops=1;
            seq(i).markerEnable=true;
            seq(i).segmentAdvance='Auto';
        case 0
            seq(i).segmentNumber=1;
            seq(i).segmentLoops=1;
            seq(i).markerEnable=true;
            seq(i).segmentAdvance='Conditional';
    end
end
%% START SEQ
iqseq('define', seq, 'keepOpen', 1, 'run', 1);
%% STOP SEQ
iqseq('define', seq, 'keepOpen', 1, 'run', 0);
%%


















