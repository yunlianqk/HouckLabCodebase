addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\');
address = 'GPIB0::15::INSTR';
tek = Tek5014AWG(address);

%% How I use the code.
samplerate = 1.2e9;
addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\');

% Time axis: 0.8 ns sampling interval, 30 us total length
taxis = 0:1/samplerate:30e-6;
pulsegen1.timeaxis = taxis;
% Channel 1: 1 MHz sine wave between 0 and 10 us
pulsegen1.waveform1 = sin(2*pi*1e6*taxis).*(taxis <= 10e-6);
% Channel 2: Two Gaussian pulses with sigma = 100 ns, center = 5 us and 6 us
% A window of 8*sigma is used to enforce the pulse width
sigma = 100e-9;
ctr1 = 5e-6;
ctr2 = 6e-6;
pulsegen1.waveform2 = exp(-(taxis-ctr1).^2/(2*sigma^2)) ...
                     .*(taxis >= ctr1-4*sigma & taxis <= ctr1+4*sigma) ...
                   + 0.5*exp(-(taxis-ctr2).^2/(2*sigma^2)) ...
                     .*(taxis >= ctr2-4*sigma & taxis <= ctr2+4*sigma);

DigWform1 = ADConvert(pulsegen1.waveform1, 'ch');
% DigWform1_Markers = ADConvert(combinedBlank,combinedTrig,'ch_marker');
                 

%%
pulseParam.pulseDur = 300e-6;
pulseParam.sigAmp = .5;
pulseParam.waitTime = 100e-6;
pulseParam.sigFreq = 7.6e9;
pulseParam.IF = 50e6;
pulseParam.buffer = 50e-6;
pulseParam.loAmplitude = 0;
pulseParam.samplingRate = 1e9; % Lot of these are just the variables I defined for making the 

waveFormLength_sig = pulseParam.buffer*2 + pulseParam.waitTime + pulseParam.pulseDur

minPoints_sig = waveFormLength_sig*pulseParam.samplingRate
numPoints_sig = minPoints_sig ;%+ mod(minPoints_sig,256)

taxis_sig = 0:1/pulseParam.samplingRate:(numPoints_sig-1)/pulseParam.samplingRate; % Must be multiple of 256

waveFormLength_back = pulseParam.buffer*2 + pulseParam.waitTime + pulseParam.pulseDur

minPoints_back = waveFormLength_back*pulseParam.samplingRate;
numPoints_back = minPoints_back ;%+ mod(minPoints_back,256);

taxis_back = 0:1/pulseParam.samplingRate:(numPoints_back-1)/pulseParam.samplingRate; % Must be multiple of 256

gateSeq(1) = pulselib.gateSequence();
gateSeq(2) = pulselib.gateSequence();

% 
gateSeq(1).append(pulselib.delay(pulseParam.buffer)); % Delay
gateSeq(2).append(pulselib.delay(pulseParam.buffer)); % Delay

pulseParam.signal = pulselib.measPulse(pulseParam.pulseDur+pulseParam.waitTime, 1);
pulseParam.background = pulselib.measPulse(pulseParam.pulseDur+pulseParam.waitTime, 1);
pulseParam.blank = pulselib.measPulse(2*window+pulseParam.pulseDur+pulseParam.waitTime, 1);
pulseParam.blank2 = pulselib.measPulse(2*window+pulseParam.pulseDur+pulseParam.waitTime, 1);

gateSeq(1).append(pulseParam.background); % Background
gateSeq(2).append(pulseParam.signal); % Signal

gateSeq(1).append(pulselib.delay(pulseParam.buffer)); % Delay
gateSeq(2).append(pulselib.delay(pulseParam.buffer)); % Delay

[iBackWaveform, qBackWaveform] = gateSeq(1).uwWaveforms(taxis_back, tstart);
backWaveform = iBackWaveform;
clear iBackWaveform qBackWaveform

[iSigWaveform, qSigWaveform] = gateSeq(2).uwWaveforms(taxis_sig, tstart);
sigWaveform = iSigWaveform ;
clear iSigWaveform qSigWaveform

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


%%
% Start pulse generation. 
fprintf(tek.instrhandle,'awgc:run');
%% Stop pulse gen. Useful for synchronizign with the card. 
 fprintf(tek.instrhandle,'awgc:stop');
%%

