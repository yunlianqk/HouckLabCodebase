function  LoadNewWaveforms_TEKv4(tekawg,pulseParam)
% Function to load simple waveforms for Correlation measurement.
% Two segments - Signal (square pulse) and Background (0 amplitude square
% pulse). 
pulseParam.samplingRate = 1e9;
scalingfactor = 254;
window = 1e-6;
tstart = 00e-9;
syncTime = 20e-6;
pulseDur = 300e-6;
waitTime = 100e-6;
startbuff = 50e-6;
endbuff = 50e-6;

waveFormLength_sig = pulseParam.buffer*2 + pulseParam.waitTime + pulseParam.pulseDur
% waveFormLength = window + pulseParam.buffer + pulseParam.waitTime + pulseParam.pulseDur;

minPoints_sig = waveFormLength_sig*pulseParam.samplingRate
numPoints_sig = minPoints_sig ;%+ mod(minPoints_sig,256)

taxis_sig = 0:1/pulseParam.samplingRate:(numPoints_sig-1)/pulseParam.samplingRate; % Must be multiple of 256

waveFormLength_back = pulseParam.buffer*2 + pulseParam.waitTime + pulseParam.pulseDur - syncTime
% waveFormLength = window + pulseParam.buffer + pulseParam.waitTime + pulseParam.pulseDur;

minPoints_back = waveFormLength_back*pulseParam.samplingRate;
numPoints_back = minPoints_back ;%+ mod(minPoints_back,256);

taxis_back = 0:1/pulseParam.samplingRate:(numPoints_back-1)/pulseParam.samplingRate; % Must be multiple of 256

gateSeq(1) = pulselib.gateSequence();
gateSeq(2) = pulselib.gateSequence();

% 
gateSeq(1).append(pulselib.delay(pulseParam.buffer)); % Delay
gateSeq(2).append(pulselib.delay(pulseParam.buffer)); % Delay
% gateSeq(3).append(pulselib.delay(pulseParam.buffer - window)); % Delay
% gateSeq(4).append(pulselib.delay(pulseParam.buffer - window)); % Delay

pulseParam.signal = pulselib.measPulse(pulseParam.pulseDur+pulseParam.waitTime, 1);
pulseParam.background = pulselib.measPulse(pulseParam.pulseDur+pulseParam.waitTime, 1);
pulseParam.blank = pulselib.measPulse(2*window+pulseParam.pulseDur+pulseParam.waitTime, 1);
pulseParam.blank2 = pulselib.measPulse(2*window+pulseParam.pulseDur+pulseParam.waitTime, 1);

gateSeq(1).append(pulseParam.background); % Background
gateSeq(2).append(pulseParam.signal); % Signal
% gateSeq(3).append(pulseParam.blank); % Signal
% gateSeq(4).append(pulseParam.blank2); % Signal

gateSeq(1).append(pulselib.delay(pulseParam.buffer)); % Delay
gateSeq(2).append(pulselib.delay(pulseParam.buffer-syncTime)); % Delay
% gateSeq(3).append(pulselib.delay(pulseParam.buffer - window)); % Delay
% gateSeq(4).append(pulselib.delay(pulseParam.buffer - window-syncTime)); % Delay

[iBackWaveform, qBackWaveform] = gateSeq(1).uwWaveforms(taxis_back, tstart);
backWaveform = iBackWaveform;
clear iBackWaveform qBackWaveform

[iSigWaveform, qSigWaveform] = gateSeq(2).uwWaveforms(taxis_sig, tstart);
sigWaveform = iSigWaveform ;
clear iSigWaveform qSigWaveform

% [iBlankWaveform, qBlankWaveform] = gateSeq(3).uwWaveforms(taxis_sig, tstart);
% blankWaveform = iBlankWaveform ;
% clear iBlankWaveform qBlankWaveform
% 
% [iBlankWaveform, qBlankWaveform] = gateSeq(4).uwWaveforms(taxis_back, tstart);
% blankWaveform2 = iBlankWaveform ;
% clear iBlankWaveform qBlankWaveform
% clear gateSeq

% Trigger Waveform
trigWaveform_sig = ones(1,length(taxis_sig)).*(taxis_sig>(pulseParam.buffer+pulseParam.waitTime)).*(taxis_sig<(pulseParam.buffer+pulseParam.waitTime +1e-6));
trigWaveform_back = ones(1,length(taxis_back)).*(taxis_back>(pulseParam.buffer+pulseParam.waitTime)).*(taxis_back<(pulseParam.buffer+pulseParam.waitTime +1e-6));

% figure(9); hold off;
% plot(taxis,sigWaveform);
% hold on; plot(taxis, trigWaveform, 'g')

% Combine Signal and background pulses into 1 long pulse. Get timing of
% triggerwaveform to match. 
combinedCh1 = scalingfactor*[sigWaveform backWaveform];
% combinedBlank = [blankWaveform blankWaveform2];

combinedTrig = [trigWaveform_sig trigWaveform_back];

% plot(combinedTrig);
% hold on; plot(combinedCh1);
% combinedBlank = [blankWaveform blankWaveform];
% % combinedBlank = [backWaveform backWaveform];

% combinedCh1 = scalingfactor*[sigWaveform];
% combinedBlank = [blankWaveform]; 
% combinedTrig = [trigWaveform_sig];

% Download waveforms
% fprintf(tekawg, 'wlis:wav:del all');

fprintf(tekawg,'awgc:stop');
fprintf(tekawg, 'awgc:rmod trig');

%load waveforms onto waveform list
DigWform1 = ADConvert(combinedCh1, 'ch');
DigWform1_Markers = ADConvert(combinedBlank,combinedTrig,'ch_marker');
WformName1 = 'ch3';
TekTransferWform2(tekawg, WformName1, DigWform1, DigWform1_Markers, length(combinedCh1));

% DigWform2 = ADConvert(combinedBlank, 'ch');
% DigWform2_Markers = ADConvert(combinedTrig,combinedTrig,'ch_marker');
% WformName2 = 'ch4';
% TekTransferWform2(tekawg, WformName2, DigWform2, DigWform2_Markers, waveFormLength*2);

%load waveforms from the list onto the channels
fprintf(tekawg, 'sour3:wav "ch3" ');
fprintf(tekawg, 'output3 on');
% fprintf(tekawg, 'sour2:wav "ch2" ');
% fprintf(tekawg, 'output2 on');
fprintf(tekawg,'awgc:run');

