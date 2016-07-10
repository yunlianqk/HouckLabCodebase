%% PNAX Spec worksheet - use github style Object Oriented Code to do 
% simultaneous transmission and spec as a flux or voltage trajectory is
% traversed.

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.0001;yoko1.rampinterval=.1;
yoko2.rampstep=.0001;yoko2.rampinterval=.1;
yoko3.rampstep=.0001;yoko3.rampinterval=.1;
% CM = [1 0 0;  0 1 0; 0 0 1;]
% f0 = [0; 0; 0;];

CM = [.0845 0 0;  0 0.5597 0; .5659 -.4699 2.3068;]
f0 = [0; -.1975; -.1655;];
fc=fluxController(CM,f0);

%% Switch to transmission channel and update settings
transWaitTime=5;
transparams.start = 5.85e9;
transparams.stop = 5.95e9;
transparams.points =1001;
transparams.power = -40;
transparams.averages = 65536;
transparams.ifbandwidth = 10e3;
transparams.trace = 1;
transparams.meastype = 'S21';
transparams.format = 'MLOG';
% pnax.transparams = transparams;
% pnax.SetActiveTrace(1);pnax.SetTransParams();
S41transparams=transparams;
S41transparams.trace=5;
S41transparams.meastype='S41';
S41transparams.format = 'MLOG';
pnax.S41transparams = S41transparams;
pnax.SetActiveTrace(5);pnax.SetS41TransParams();
% [transamp, transph, S41transamp, S41transph] = pnax.FastReadS21andS41Trans(transWaitTime);
pnax.ClearChannelAverages(pnax.S41transchannel);
pause(transWaitTime);
pnax.SetActiveTrace(5);
S41transamp=pnax.Read();
pnax.SetActiveTrace(6);
S41transph = pnax.Read();
freqvector=pnax.GetAxis();
figure(56);
% subplot(2,1,1);plot(freqvector/1e9,transamp,'b',freqvector/1e9,S41transamp,'r');title('Amplitude - S21 blue, S41 red');
% subplot(2,1,2);plot(freqvector/1e9,transph,'b',freqvector/1e9,S41transph,'r');
subplot(2,1,1);plot(freqvector/1e9,S41transamp,'r');title('Amplitude - S41 red');
subplot(2,1,2);plot(freqvector/1e9,S41transph,'r');
%%
pnax.SetActiveTrace(5);
S41transamp=pnax.Read();
pnax.SetActiveTrace(6);
S41transph = pnax.Read();
freqvector=pnax.GetAxis();
figure(56);
% subplot(2,1,1);plot(freqvector/1e9,transamp,'b',freqvector/1e9,S41transamp,'r');title('Amplitude - S21 blue, S41 red');
% subplot(2,1,2);plot(freqvector/1e9,transph,'b',freqvector/1e9,S41transph,'r');
subplot(2,1,1);plot(freqvector/1e9,S41transamp,'r');title('Amplitude - S41 red');
subplot(2,1,2);plot(freqvector/1e9,S41transph,'r');

%% Compensate Electrical Delay
pnax.CompensateElectricalDelay(pnax.S41transchannel,6)



%% find cavity peak frequency and optimal phase contrast bias point
transAmpLine = S41transamp; transPhaseLine=S41transph;
% choose max for a transmission peak and min for a reflection dip!
[peakVal,peakInd] = max(transAmpLine); peakFreq = freqvector(peakInd);
% [peakVal,peakInd] = min(transAmpLine); peakFreq = trans.v_freq(peakInd);
figure(662);
subplot(2,1,1);plot(freqvector/1e9,transAmpLine);
title('Transmission [MLOG]')
hold on; vline(peakFreq/1e9); hold off
subplot(2,1,2);plot(freqvector/1e9,transPhaseLine);
hold on; vline(peakFreq/1e9); hold off
title('Transmission [Unwrapped phase]')


%% Switch to spec channels and update settings
% S21 set and read
specWaitTime = 30;
specparams.cwpower = -45;
specparams.start = 6e9;
specparams.stop = 10e9;
specparams.points = 6001;
specparams.power = -45;
specparams.averages = 10000;
specparams.ifbandwidth = 100e3;
specparams.cwfreq=peakFreq;
specparams.trace=3;
specparams.meastype='S21';
specparams.format='MLOG';
% pnax.specparams=specparams;
% pnax.SetActiveTrace(3);pnax.SetSpecParams();
% pnax.ClearChannelAverages(pnax.specchannel);
% pause(specWaitTime);
% specamp=pnax.Read();
% pnax.SetActiveTrace(4);
% specph=pnax.Read();

% S41 set and read
S41specparams=specparams;
S41specparams.trace=7;
S41specparams.meastype='S41';
S41specparams.format='MLOG';
pnax.S41specparams=S41specparams;
pnax.SetActiveTrace(7);pnax.SetS41SpecParams();
pnax.ClearChannelAverages(pnax.S41specchannel);
pause(specWaitTime);
S41specamp=pnax.Read();
pnax.SetActiveTrace(8);
S41specph=pnax.Read();
freqvector=pnax.GetAxis();
figure(57);
% subplot(2,2,1);plot(freqvector/1e9,specamp)
% subplot(2,2,2);plot(freqvector/1e9,specph)
subplot(2,2,3);plot(freqvector/1e9,S41specamp)
subplot(2,2,4);plot(freqvector/1e9,S41specph)
%%
pnax.SetActiveTrace(7);
S41specamp=pnax.Read();
pnax.SetActiveTrace(8);
S41specph=pnax.Read();
freqvector=pnax.GetAxis();
figure(57);
subplot(2,2,3);plot(freqvector/1e9,S41specamp)
subplot(2,2,4);plot(freqvector/1e9,S41specph)
