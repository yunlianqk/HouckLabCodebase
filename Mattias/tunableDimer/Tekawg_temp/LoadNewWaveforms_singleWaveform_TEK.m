function  LoadNewWaveforms_singleWaveform_TEK(tekawg,pulseparams)
% 

waveFormLength_sig = pulseparams.buffer*2 + pulseparams.waitTime + pulseparams.pulseDur;

minPoints_sig = waveFormLength_sig*pulseparams.samplingRate;
numPoints_sig = minPoints_sig ; %+ mod(minPoints_sig,256)

taxis_sig = 0:1/pulseparams.samplingRate:(numPoints_sig-1)/pulseparams.samplingRate; % Must be multiple of 256

% % Measurement Pulse
% pulseparams.measPulse = pulselib.measPulse(pulseparams.pulseDur+pulseparams.waitTime, 1);
% [iSigWaveform, qSigWaveform] = pulseparams.measPulse.uwWaveforms(taxis_sig, pulseparams.tstart);
% sigWaveform = iSigWaveform ;
% clear iSigWaveform qSigWaveform
% ch3 = pulseparams.scalingfactor*sigWaveform;


% Qubit Pulse
pulseparams.qubitPulse = pulselib.singleGate('X180');
pulseparams.qubitPulse.sigma = 12.0e-8;
% pulseparams.qubitPulse.
[iSigWaveform, qSigWaveform] = pulseparams.qubitPulse.uwWaveforms(taxis_sig, pulseparams.tstart);
qubitWaveform = iSigWaveform ;
clear iSigWaveform qSigWaveform
ch2 = pulseparams.scalingfactor*qubitWaveform;


% Trigger Pulse
% trigWaveform_sig = ones(1,length(taxis_sig)).*(taxis_sig>(pulseparams.buffer+pulseparams.waitTime)).*(taxis_sig<(pulseparams.buffer+pulseparams.waitTime +1e-6));
% put the trigger before the pi pulse
trigWaveform_sig = ones(1,length(taxis_sig)).*(taxis_sig>(pulseparams.buffer+pulseparams.waitTime)).*(taxis_sig<(pulseparams.buffer+pulseparams.waitTime+1e-6));
trig = trigWaveform_sig;



%Download waveforms
fprintf(tekawg, 'wlis:wav:del all');

fprintf(tekawg,'awgc:stop');
fprintf(tekawg, 'awgc:rmod trig');

%load waveforms onto waveform list
DigWform1 = ADConvert(ch3, 'ch');
WformName1 = 'ch3';
DigWform1_Markers = ADConvert(trig,trig,'ch_marker');
TekTransferWform2(tekawg, WformName1, DigWform1, DigWform1_Markers, length(ch3));

%load waveforms onto waveform list
DigWform1 = ADConvert(ch2, 'ch');
WformName1 = 'ch2';
DigWform1_Markers = ADConvert(trig,trig,'ch_marker');
TekTransferWform2(tekawg, WformName1, DigWform1, DigWform1_Markers, length(ch2));

%load waveforms from the list onto the channels
% fprintf(tekawg, 'sour3:wav "ch3" ');
% fprintf(tekawg, 'output3 on');
fprintf(tekawg, 'sour2:wav "ch2" ');
fprintf(tekawg, 'sour2:Dig:Voltage:OFFSET 0.5')
fprintf(tekawg, 'output2 on');
fprintf(tekawg,'awgc:run');

