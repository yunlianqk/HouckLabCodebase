addpath('C:\Users\newforce\Documents\GitHub\HouckLabMeasurementCode');
% Initialize awg object
% Choose settings in IQ config window -> press Ok
% Import FIR filter -> press Ok
awg = M8195AWG();
%% Generate vector for typical Rabi experiment
waveLength=20e-6;
tAxis=(1/awg.samplerate:1/awg.samplerate:waveLength);
% Readout pulse parameters
read.Amp=0.2;
read.Freq=6e9;
read.start=10e-6;
read.length=5e-6;
read.buffer=10e-9;
% Qubit gaussian pulse parameters
qubit.Amp=0.7;
qubit.Freq=4e9;
qubit.sigma=50e-9;
qubit.cutoff=4*qubit.sigma;
qubit.center=read.start-read.buffer-qubit.cutoff/2;
% Base Gaussian waveform
gauss=qubit.Amp.*exp(-(tAxis-qubit.center).^2/(2*qubit.sigma^2));
% Apply cutoff
offset=qubit.Amp*exp(-qubit.cutoff^2/(8*qubit.sigma^2));
gaussC=(gauss-offset).*(tAxis>(qubit.center-qubit.cutoff/2)) ...
                     .*(tAxis<(qubit.center+qubit.cutoff/2));
% Normalize
if max(abs(gaussC)) ~=abs(qubit.Amp)
    gaussC=gaussC/max(abs(gaussC))*abs(qubit.Amp);
end

% Channel 1 waveform = Qubit pulse + Readout 
waveform1 = read.Amp*(tAxis>read.start & tAxis<read.start+read.length).*cos(2*pi*read.Freq*tAxis)+...
            gaussC.*cos(2*pi*qubit.Freq*tAxis);
        
% Channel 2 waveform = LO
waveform2 = read.Amp*(tAxis>read.start & tAxis<read.start+read.length).*cos(2*pi*read.Freq*tAxis);

figure();plot(tAxis,waveform1+2.5,'b',tAxis,waveform2,'r')
legend('Qubit + Readout pulses', 'LO pulse','Location','NorthWest')

% zero vector after waveform
% used for setting it as a 'conditional' advance
endbuffer = zeros(1,awg.minSegSize);
%% Create waveform library

% Waveforms for Ch1
WaveLib(1).waveform = waveform1;
WaveLib(1).channelMap = [1 0;0 0;0 0;0 0];
WaveLib(1).segNumber = 1;
WaveLib(1).keepOpen = 1;
WaveLib(1).run = 0;
WaveLib(1).correction = 1;

WaveLib(2).waveform = endbuffer;
WaveLib(2).channelMap = [1 0;0 0;0 0;0 0];
WaveLib(2).segNumber = 2;
WaveLib(2).keepOpen = 1;
WaveLib(2).run = 0;
WaveLib(2).correction = 0;

% Waveforms for Ch4
WaveLib(3).waveform = waveform2;
WaveLib(3).channelMap = [0 0;0 0;0 0;1 0];
WaveLib(3).segNumber = 1;
WaveLib(3).keepOpen = 1;
WaveLib(3).run = 0;
WaveLib(3).correction = 1;

WaveLib(4).waveform = endbuffer;
WaveLib(4).channelMap = [0 0;0 0;0 0;1 0];
WaveLib(4).segNumber = 2;
WaveLib(4).keepOpen = 1;
WaveLib(4).run = 0;
WaveLib(4).correction = 0;
%% Send library to the awg
awg.ApplyCorrection(WaveLib);
awg.Wavedownload(WaveLib);

% Look at the corrected waveform
% figure();plot(tAxis,WaveLib(1).waveform); ylim([-1.5,1.5])
%% Setup sequence playlist
clear PlayList1
% clear PlayList4

%Channel 1 playlist
PlayList1(1).segmentNumber=1;
PlayList1(1).segmentLoops=1;
PlayList1(1).markerEnable=true;
PlayList1(1).segmentAdvance='Auto';

PlayList1(2).segmentNumber=2;
PlayList1(2).segmentLoops=1;
PlayList1(2).markerEnable=true;
PlayList1(2).segmentAdvance='Conditional';

%Channel 4 playlist
% PlayList4(1).segmentNumber=1;
% PlayList4(1).segmentLoops=1;
% PlayList4(1).markerEnable=true;
% PlayList4(1).segmentAdvance='Auto';
% 
% PlayList4(2).segmentNumber=2;
% PlayList4(2).segmentLoops=1;
% PlayList4(2).markerEnable=true;
% PlayList4(2).segmentAdvance='Conditional';
%% Run sequence
awg.SeqRun(PlayList);
% iqseq('define', PlayList4, 'keepOpen', 1, 'run', 1);
