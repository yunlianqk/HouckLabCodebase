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
% varying amplitudes
qubit.Amp=(0.2:0.2:1);
qubit.Freq=4e9;
qubit.sigma=50e-9;
qubit.cutoff=4*qubit.sigma;
qubit.center=read.start-read.buffer-qubit.cutoff/2;
for i=1:length(qubit.Amp)
    % Base Gaussian waveform
    gauss=qubit.Amp(i).*exp(-(tAxis-qubit.center).^2/(2*qubit.sigma^2));
    % Apply cutoff
    offset=qubit.Amp(i)*exp(-qubit.cutoff^2/(8*qubit.sigma^2));
    gaussC(i,:)=(gauss-offset).*(tAxis>(qubit.center-qubit.cutoff/2)) ...
                         .*(tAxis<(qubit.center+qubit.cutoff/2));
    % Normalize
    if max(abs(gaussC(i,:))) ~=abs(qubit.Amp(i))
        gaussC(i,:)=gaussC(i,:)/max(abs(gaussC(i,:)))*abs(qubit.Amp(i));
    end

end

% Channel 1 waveform = Qubit pulse + Readout
for i=1:length(qubit.Amp)
    waveform1(i,:) = read.Amp*(tAxis>read.start & tAxis<read.start+read.length).*cos(2*pi*read.Freq*tAxis)+...
                gaussC(i,:).*cos(2*pi*qubit.Freq*tAxis);
end
% Channel 2 waveform = LO
waveform2 = read.Amp*(tAxis>read.start & tAxis<read.start+read.length).*cos(2*pi*read.Freq*tAxis);

figure();
subplot(1,2,1); hold on;
for i=1:length(qubit.Amp)
    plot(tAxis,waveform1(i,:)+2*i,'b')
end
hold off;
subplot(1,2,2)
plot(tAxis,waveform2,'r')
%% Create waveform library

for i=1:length(qubit.Amp)
    % Waveforms for Ch1
    WaveLib(2*i-1).waveform = waveform1(i,:);
    WaveLib(2*i-1).channelMap = [1 0;0 0;0 0;0 0];
    WaveLib(2*i-1).segNumber = i;
    WaveLib(2*i-1).keepOpen = 1;
    WaveLib(2*i-1).run = 0;
    WaveLib(2*i-1).correction = 1;
    
    % Waveforms for Ch4
    WaveLib(2*i).waveform = waveform2;
    WaveLib(2*i).channelMap = [0 0;0 0;0 0;1 0];
    WaveLib(2*i).segNumber = i;
    WaveLib(2*i).keepOpen = 1;
    WaveLib(2*i).run = 0;
    WaveLib(2*i).correction = 1;
end
%% Send library to the awg
awg.ApplyCorrection(WaveLib);
awg.Wavedownload(WaveLib);
%% Setup sequence playlist
clear PlayList
for i=1:(length(qubit.Amp)-1)
    %Channel 1+4 playlist
    PlayList(i).segmentNumber=i;
    PlayList(i).segmentLoops=1;
    PlayList(i).markerEnable=true;
    PlayList(i).segmentAdvance='Stepped';
end

% last element of playlist needs to have 'auto' segment advance mode
last=length(qubit.Amp);
PlayList(last).segmentNumber=last;
PlayList(last).segmentLoops=1;
PlayList(last).markerEnable=true;
PlayList(last).segmentAdvance='Auto';

%% Run sequence
awg.SeqRun(PlayList);