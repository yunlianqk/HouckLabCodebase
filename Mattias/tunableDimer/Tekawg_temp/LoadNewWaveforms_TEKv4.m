function  LoadNewWaveforms_TEKv4(tekawg,pulseparams)
% 

waveFormLength_sig = pulseparams.buffer*2 + pulseparams.waitTime + pulseparams.pulseDur;

minPoints_sig = waveFormLength_sig*pulseparams.samplingRate;
numPoints_sig = minPoints_sig ; %+ mod(minPoints_sig,256)

taxis_sig = 0:1/pulseparams.samplingRate:(numPoints_sig-1)/pulseparams.samplingRate; % Must be multiple of 256

waveFormLength_back = pulseparams.buffer*2 + pulseparams.waitTime + pulseparams.pulseDur;

minPoints_back = waveFormLength_back*pulseparams.samplingRate;
numPoints_back = minPoints_back ;%+ mod(minPoints_back,256);

taxis_back = 0:1/pulseparams.samplingRate:(numPoints_back-1)/pulseparams.samplingRate; % Must be multiple of 256

gateSeq(1) = pulselib.gateSequence();
gateSeq(2) = pulselib.gateSequence();

gateSeq(1).append(pulselib.delay(pulseparams.buffer)); % Delay
gateSeq(2).append(pulselib.delay(pulseparams.buffer)); % Delay

pulseparams.signal = pulselib.measPulse(pulseparams.pulseDur+pulseparams.waitTime, 1);
pulseparams.background = pulselib.measPulse(pulseparams.pulseDur+pulseparams.waitTime, 1);


gateSeq(1).append(pulseparams.background); % Background
gateSeq(2).append(pulseparams.signal); % Signal

gateSeq(1).append(pulselib.delay(pulseparams.buffer)); % Delay
gateSeq(2).append(pulselib.delay(pulseparams.buffer)); % Delay


[iBackWaveform, qBackWaveform] = gateSeq(1).uwWaveforms(taxis_back, pulseparams.tstart);
backWaveform = iBackWaveform;
clear iBackWaveform qBackWaveform

[iSigWaveform, qSigWaveform] = gateSeq(2).uwWaveforms(taxis_sig, pulseparams.tstart);
sigWaveform = iSigWaveform ;
clear iSigWaveform qSigWaveform

% Trigger Waveform
trigWaveform_sig = ones(1,length(taxis_sig)).*(taxis_sig>(pulseparams.buffer+pulseparams.waitTime)).*(taxis_sig<(pulseparams.buffer+pulseparams.waitTime +1e-6));
trigWaveform_back = ones(1,length(taxis_back)).*(taxis_back>(pulseparams.buffer+pulseparams.waitTime)).*(taxis_back<(pulseparams.buffer+pulseparams.waitTime +1e-6));

% figure(9); hold off;
% plot(taxis,sigWaveform);
% hold on; plot(taxis, trigWaveform, 'g')

% Combine Signal and background pulses into 1 long pulse. Get timing of
% triggerwaveform to match. 
combinedCh1 = pulseparams.scalingfactor*[sigWaveform backWaveform];
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
WformName1 = 'ch3';
DigWform1_Markers = ADConvert(combinedTrig,combinedTrig,'ch_marker');
TekTransferWform2(tekawg, WformName1, DigWform1, DigWform1_Markers, length(combinedCh1));


% DigWform1_Markers = ADConvert(combinedBlank,combinedTrig,'ch_marker');
% WformName1 = 'ch3';
% TekTransferWform2(tekawg, WformName1, DigWform1, DigWform1_Markers, length(combinedCh1));

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

