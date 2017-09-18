function [ PlayList ] = LoadNewWaveforms_UP(  pulseParam )
% Function to load simple waveforms for Correlation measurement.
% Two segments - Signal (square pulse) and Background (0 amplitude square
% pulse). 

tstart = 20e-9;
minPoints = (pulseParam.buffer + pulseParam.waitTime+pulseParam.pulseDur + tstart+100e-6)*pulseParam.samplingRate;
numPoints = minPoints + mod(minPoints,256);

taxis = 0:1/pulseParam.samplingRate:(numPoints-1)/pulseParam.samplingRate; % Must be multiple of 256

pulseParam.signal = pulselib.measPulse(pulseParam.pulseDur+pulseParam.waitTime, pulseParam.sigAmp);
pulseParam.background = pulselib.measPulse(pulseParam.pulseDur+pulseParam.waitTime, 0);
pulseParam.blank = pulselib.measPulse(10e6+pulseParam.pulseDur+pulseParam.waitTime, 0.8);

gateSeq(1) = pulselib.gateSequence();
gateSeq(2) = pulselib.gateSequence();
gateSeq(3) = pulselib.gateSequence();

gateSeq(1).append(pulselib.delay(10e-6)); % Delay
gateSeq(2).append(pulselib.delay(10e-6)); % Delay
gateSeq(3).append(pulselib.delay(5e-6)); % Delay

gateSeq(1).append(pulseParam.background); % Background
gateSeq(2).append(pulseParam.signal); % Signal
gateSeq(3).append(pulseParam.blank); % Signal

gateSeq(1).append(pulselib.delay(10e-6)); % Delay
gateSeq(2).append(pulselib.delay(10e-6)); % Delay
gateSeq(3).append(pulselib.delay(5e-6)); % Delay

gateSeq(1).append(pulselib.delay(pulseParam.buffer)); % Delay
gateSeq(2).append(pulselib.delay(pulseParam.buffer)); % Delay
gateSeq(3).append(pulselib.delay(pulseParam.buffer)); % Delay

[iBackWaveform, qBackWaveform] = gateSeq(1).uwWaveforms(taxis, tstart);

backWaveform = iBackWaveform;
% clear iBackWaveform qBackWaveform

[iSigWaveform, qSigWaveform] = gateSeq(2).uwWaveforms(taxis, tstart);
sigWaveform = iSigWaveform ;
% clear iSigWaveform qSigWaveform

[iBlankWaveform, qBlankWaveform] = gateSeq(3).uwWaveforms(taxis, tstart);
blankWaveform = iBlankWaveform ;
% clear iBlankWaveform qBlankWaveform

% LO Waveform
% loWaveform = pulseParam.loAmplitude ...
%     *cos(2*pi*(pulseParam.sigFreq)*taxis);
loWaveform = zeros(1,length(taxis));

% Trigger Waveform
% trigWaveform = ones(1,length(taxis)).*(taxis>10e-9).*(taxis<510e-9);
trigWaveform = ones(1,length(taxis)).*(taxis>pulseParam.waitTime + 10e-9).*(taxis<pulseParam.waitTime +510e-9);
figure(9); hold off;
plot(taxis,sigWaveform);
hold on; plot(taxis, trigWaveform, 'g')

clear gateSeq
% Download waveforms. iqdownload
% channel 1: [1 0; 0 0; 0 0; 0 0]; channel 2: [0 0; 1 0; 0 0; 0 0]
% Ch1 = Signal. Ch2 = LO. Ch3 = trigger for card

segID = 1;
channelID = [1 0; 0 0; 0 0; 0 0];
iqdownload(sigWaveform, pulseParam.samplingRate, ...
    'channelMapping', channelID, ...
    'segmentNumber', segID, ...
    'keepOpen', 1, ...
    'run', 0, ...
    'amplitude', 1, ...
    'marker', trigWaveform);

segID = 2;
iqdownload(backWaveform, pulseParam.samplingRate, ...
    'channelMapping', channelID, ...
    'segmentNumber', segID, ...
    'keepOpen', 1, ...
    'run', 0, ...
    'amplitude', 1, ...
    'marker', trigWaveform);

segID = 1;
channelID = [0 0; 1 0; 0 0; 0 0];
iqdownload(blankWaveform, pulseParam.samplingRate, ...
    'channelMapping', channelID, ...
    'segmentNumber', segID, ...
    'keepOpen', 1, ...
    'run', 0, ...
    'amplitude', 1, ...
    'marker', blankWaveform);

segID = 2;
iqdownload(loWaveform, pulseParam.samplingRate, ...
    'channelMapping', channelID, ...
    'segmentNumber', segID, ...
    'keepOpen', 1, ...
    'run', 0, ...
    'amplitude', 0, ...
    'marker', loWaveform);

clear segID channelID
% Create Playlist
clear PlayList
PlayList(1).segmentNumber=1;
PlayList(1).segmentLoops=1;
PlayList(1).markerEnable=true;
PlayList(1).segmentAdvance='Stepped';

% last element of playlist needs to have 'auto' segment advance mode
PlayList(2).segmentNumber=2;
PlayList(2).segmentLoops=1;
PlayList(2).markerEnable=true;
PlayList(2).segmentAdvance='Auto';
% pause(1);
end
%%% OLD METHOD
% function [ PlayList ] = LoadNewWaveforms(  pulseParam )
% % Function to load simple waveforms for Correlation measurement.
% % Two segments - Signal (square pulse) and Background (0 amplitude square
% % pulse). 
% 
% tstart = 20e-9;
% minPoints = (pulseParam.buffer + pulseParam.waitTime+pulseParam.pulseDur + tstart)*pulseParam.samplingRate;
% numPoints = minPoints + mod(minPoints,256);
% 
% taxis = 0:1/pulseParam.samplingRate:(numPoints-1)/pulseParam.samplingRate; % Must be multiple of 256
% 
% pulseParam.signal = pulselib.measPulse(pulseParam.pulseDur+pulseParam.waitTime, pulseParam.sigAmp);
% pulseParam.background = pulselib.measPulse(pulseParam.pulseDur+pulseParam.waitTime, 0);
% 
% gateSeq(1) = pulselib.gateSequence();
% gateSeq(2) = pulselib.gateSequence();
% 
% % gateSeq(1).append(pulselib.delay(pulseParam.waitTime)); % Delay
% % gateSeq(2).append(pulselib.delay(pulseParam.waitTime)); % Delay
% 
% gateSeq(1).append(pulseParam.background); % Background
% gateSeq(2).append(pulseParam.signal); % Signal
% 
% gateSeq(1).append(pulselib.delay(pulseParam.buffer)); % Delay
% gateSeq(2).append(pulselib.delay(pulseParam.buffer)); % Delay
% 
% [iBackWaveform, qBackWaveform] = gateSeq(1).uwWaveforms(taxis, tstart);
% 
% % backWaveform = iBackWaveform;
% backWaveform = iBackWaveform.*cos(2*pi*pulseParam.sigFreq*taxis);% ...
%   %  + qBackWaveform.*sin(2*pi*pulseParam.sigFreq*taxis);
% clear iBackWaveform qBackWaveform
% 
% [iSigWaveform, qSigWaveform] = gateSeq(2).uwWaveforms(taxis, tstart);
% 
% % noisySigWaveform = iSigWaveform.*(1.5*randn(size(iSigWaveform)));
% 
% % Fs = pulseParam.samplingRate;
% % Nfft = length(iSigWaveform);
% % df = Fs/Nfft;
% % f = (0:Nfft-1)*df;
% % f(f>=Fs/2) = f(f>=Fs/2) - Fs;
% % f_norm = fftshift(f);
% % gaussfilt = normpdf(f_norm, 0, 5e6);
% 
% % n_f = fftshift(fft(noisySigWaveform)).*gaussfilt; 
% % noisySig = ifft(ifftshift(n_f), 'symmetric')*length(n_f);
% % sigWaveform = noisySig.*cos(2*pi*pulseParam.sigFreq*taxis);
% % plot(sigWaveform)
% % noisySigWaveform = iSigWaveform.*(1.5*randn(size(iSigWaveform)));
% % sigWaveform = noisySigWaveform.*cos(2*pi*pulseParam.sigFreq*taxis);
% % 
% % sigWaveform = iSigWaveform.*cos(2*pi*pulseParam.sigFreq*taxis) ...
% %     + qSigWaveform.*sin(2*pi*pulseParam.sigFreq*taxis);
% 
% sigWaveform = iSigWaveform ;
% clear iSigWaveform qSigWaveform
% 
% % LO Waveform
% % loWaveform = pulseParam.loAmplitude ...
% %     *cos(2*pi*(pulseParam.sigFreq)*taxis);
% loWaveform = zeros(1,length(taxis));
% 
% % Trigger Waveform
% % trigWaveform = ones(1,length(taxis)).*(taxis>10e-9).*(taxis<510e-9);
% trigWaveform = ones(1,length(taxis)).*(taxis>pulseParam.waitTime + 10e-9).*(taxis<pulseParam.waitTime +510e-9);
% figure(9); hold off;
% plot(taxis,sigWaveform);
% hold on; plot(taxis, trigWaveform, 'g')
% 
% clear gateSeq
% % Download waveforms. iqdownload
% % channel 1: [1 0; 0 0; 0 0; 0 0]; channel 2: [0 0; 1 0; 0 0; 0 0]
% % Ch1 = Signal. Ch2 = LO. Ch3 = trigger for card
% 
% segID = 1;
% channelID = [1 0; 0 0; 0 0; 0 0];
% iqdownload(sigWaveform, pulseParam.samplingRate, ...
%     'channelMapping', channelID, ...
%     'segmentNumber', segID, ...
%     'keepOpen', 1, ...
%     'run', 0, ...
%     'amplitude', 1, ...
%     'marker', trigWaveform);
% 
% segID = 2;
% iqdownload(backWaveform, pulseParam.samplingRate, ...
%     'channelMapping', channelID, ...
%     'segmentNumber', segID, ...
%     'keepOpen', 1, ...
%     'run', 0, ...
%     'amplitude', 1, ...
%     'marker', trigWaveform);
% 
% segID = 1;
% channelID = [0 0; 1 0; 0 0; 0 0];
% iqdownload(loWaveform, pulseParam.samplingRate, ...
%     'channelMapping', channelID, ...
%     'segmentNumber', segID, ...
%     'keepOpen', 1, ...
%     'run', 0, ...
%     'amplitude', 0, ...
%     'marker', trigWaveform);
% 
% segID = 2;
% iqdownload(loWaveform, pulseParam.samplingRate, ...
%     'channelMapping', channelID, ...
%     'segmentNumber', segID, ...
%     'keepOpen', 1, ...
%     'run', 0, ...
%     'amplitude', 0, ...
%     'marker', trigWaveform);
% 
% clear segID channelID
% % Create Playlist
% clear PlayList
% PlayList(1).segmentNumber=1;
% PlayList(1).segmentLoops=1;
% PlayList(1).markerEnable=true;
% PlayList(1).segmentAdvance='Stepped';
% 
% % last element of playlist needs to have 'auto' segment advance mode
% PlayList(2).segmentNumber=2;
% PlayList(2).segmentLoops=1;
% PlayList(2).markerEnable=true;
% PlayList(2).segmentAdvance='Auto';
% % pause(1);
% end
% 

