addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\');
address = 'GPIB0::15::INSTR';
tek = Tek5014AWG(address);

%% How I use the code. 

% pulseparams.samplingRate = 1e9;
% pulseparams.pulseDur = 10e-6;
% pulseparams.sigAmp = 1.0;
% pulseparams.waitTime = 0e-6;
% pulseparams.buffer = 1e-6;
% pulseparams.scalingfactor = 254;
% pulseparams.window = 1e-6;
% pulseparams.tstart = 0e-6;
% pulseparams.startbuff = 1e-6;
% pulseparams.endbuff = 0e-6;



triggerWaitTime = 20e-9;
samplingRate = 1e9;
scalingFactor = 254;

taxis = 0:1/samplingRate:20e-6;
tstart = 20e-9;

gatelist = {'X180'};
pulseCal = paramlib.pulseCal();
gateSeq = pulselib.gateSequence();

pulseCal.sigma = 150e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.X180Amplitude = 1.0;

gateSeq.append(pulselib.delay(5e-6));

gateSeq.append(pulseCal.X180);

[iWaveform, qWaveform] = gateSeq.uwWaveforms(taxis, tstart);
ch2 = scalingFactor*iWaveform;
clear iWaveform qWaveform

trigWaveform = ones(1,length(taxis)).*(taxis>(triggerWaitTime)).*(taxis<(triggerWaitTime+1e-6));
trig = trigWaveform;

%Download waveforms
fprintf(tek.instrhandle, 'wlis:wav:del all');

fprintf(tek.instrhandle,'awgc:stop');
fprintf(tek.instrhandle, 'awgc:rmod trig');

%load waveforms onto waveform list
DigWform1 = ADConvert(ch2, 'ch');
WformName1 = 'ch2';
DigWform1_Markers = ADConvert(trig,trig,'ch_marker');
TekTransferWform2(tek.instrhandle, WformName1, DigWform1, DigWform1_Markers, length(ch2));

%load waveforms from the list onto the channels
fprintf(tek.instrhandle, 'sour2:wav "ch2" ');
fprintf(tek.instrhandle, 'sour2:Dig:Voltage:OFFSET 0.5')
fprintf(tek.instrhandle, 'output2 on');
fprintf(tek.instrhandle,'awgc:run');
%
% Start pulse generation. 
fprintf(tek.instrhandle,'awgc:run');


% %load waveforms onto waveform list
% DigWform1 = ADConvert(ch3, 'ch');
% WformName1 = 'ch3';
% DigWform1_Markers = ADConvert(trig,trig,'ch_marker');
% TekTransferWform2(tekawg, WformName1, DigWform1, DigWform1_Markers, length(ch3));

% waveFormLength_sig = pulseparams.buffer*2 + pulseparams.waitTime + pulseparams.pulseDur;
% 
% minPoints_sig = waveFormLength_sig*pulseparams.samplingRate;
% numPoints_sig = minPoints_sig ; %+ mod(minPoints_sig,256)
% 
% taxis_sig = 0:1/pulseparams.samplingRate:(numPoints_sig-1)/pulseparams.samplingRate; % Must be multiple of 256

% % Measurement Pulse
% pulseparams.measPulse = pulselib.measPulse(pulseparams.pulseDur+pulseparams.waitTime, 1);
% [iSigWaveform, qSigWaveform] = pulseparams.measPulse.uwWaveforms(taxis_sig, pulseparams.tstart);
% sigWaveform = iSigWaveform ;
% clear iSigWaveform qSigWaveform
% ch3 = pulseparams.scalingfactor*sigWaveform;


% % Qubit Pulse
% pulseparams.qubitPulse = pulselib.singleGate('X180');
% pulseparams.qubitPulse.sigma = 12.0e-8;
% % pulseparams.qubitPulse.
% [iSigWaveform, qSigWaveform] = pulseparams.qubitPulse.uwWaveforms(taxis_sig, pulseparams.tstart);
% qubitWaveform = iSigWaveform ;
% clear iSigWaveform qSigWaveform
% ch2 = pulseparams.scalingfactor*qubitWaveform;


% Trigger Pulse
% trigWaveform_sig = ones(1,length(taxis_sig)).*(taxis_sig>(pulseparams.buffer+pulseparams.waitTime)).*(taxis_sig<(pulseparams.buffer+pulseparams.waitTime +1e-6));
% put the trigger before the pi pulse
% trigWaveform_sig = ones(1,length(taxis_sig)).*(taxis_sig>(pulseparams.buffer+pulseparams.waitTime)).*(taxis_sig<(pulseparams.buffer+pulseparams.waitTime+1e-6));
% trig = trigWaveform_sig;



% %Download waveforms
% fprintf(tekawg, 'wlis:wav:del all');
% 
% fprintf(tekawg,'awgc:stop');
% fprintf(tekawg, 'awgc:rmod trig');
% 
% %load waveforms onto waveform list
% DigWform1 = ADConvert(ch3, 'ch');
% WformName1 = 'ch3';
% DigWform1_Markers = ADConvert(trig,trig,'ch_marker');
% TekTransferWform2(tekawg, WformName1, DigWform1, DigWform1_Markers, length(ch3));
% 
% %load waveforms onto waveform list
% DigWform1 = ADConvert(ch2, 'ch');
% WformName1 = 'ch2';
% DigWform1_Markers = ADConvert(trig,trig,'ch_marker');
% TekTransferWform2(tekawg, WformName1, DigWform1, DigWform1_Markers, length(ch2));
% 
% %load waveforms from the list onto the channels
% % fprintf(tekawg, 'sour3:wav "ch3" ');
% % fprintf(tekawg, 'output3 on');
% fprintf(tekawg, 'sour2:wav "ch2" ');
% fprintf(tekawg, 'sour2:Dig:Voltage:OFFSET 0.5')
% fprintf(tekawg, 'output2 on');
% fprintf(tekawg,'awgc:run');
% %%
% % Start pulse generation. 
% fprintf(tek.instrhandle,'awgc:run');
%% Stop pulse gen. Useful for synchronizign with the card. 
%  fprintf(tek.instrhandle,'awgc:stop');
%%

