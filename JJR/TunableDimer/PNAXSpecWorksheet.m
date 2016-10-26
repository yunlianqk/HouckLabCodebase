%% PNAX Spec Optimization Worksheet

%% Update and read transmission channel
pnax.SetActiveTrace(1);
transWaitTime=10;
pnax.params.start = 5.9e9;
pnax.params.stop = 5.95e9;
pnax.params.points = 1001;
pnax.params.power = -45;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
pause(transWaitTime);

ftrans = pnax.ReadAxis();
pnax.SetActiveTrace(1);
[data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
pnax.SetActiveTrace(2);
[data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
plot(ftrans,data_transS21A,'b',ftrans,data_transS41A,'r');
% plot(ftrans,data_transS41A,'r');
% plot(ftrans,data_transS21A,'r');
subplot(2,1,2);
plot(ftrans,data_transS21P,'b',ftrans,data_transS41P,'r');
% plot(ftrans,data_transS41P,'r'); 
% plot(ftrans,data_transS21P,'r');

%% Compensate Electrical Delay - needs to be updated
pnax.SetActiveTrace(2);
pnax.CompensateElectricalDelay()

%% find cavity peak frequency and optimal phase contrast bias point
% transAmpLine = data_transS21A; transPhaseLine=data_transS21P;
transAmpLine = data_transS41A; transPhaseLine=data_transS41P;
% choose max for a transmission peak and min for a reflection dip!
[peakVal,peakInd] = max(transAmpLine); peakFreq = ftrans(peakInd);
% [peakVal,peakInd] = min(transAmpLine); peakFreq = trans.v_freq(peakInd);
figure(651);
subplot(2,1,1);plot(ftrans/1e9,transAmpLine);
title('Transmission [MLOG]')
hold on; plotlib.vline(peakFreq/1e9); hold off
subplot(2,1,2);plot(ftrans/1e9,transPhaseLine);
hold on; plotlib.vline(peakFreq/1e9); hold off
title('Transmission [Unwrapped phase]')


%% Switch to spec channels and update settings
pnax.SetActiveTrace(3);
specWaitTime = 300;
pnax.params.cwpower = -45;
pnax.params.start =  4e9;
pnax.params.stop = 5.8e9;
% pnax.params.start =  3.2e9;
% pnax.params.stop = 3.4e9;
pnax.params.points = 10001;
% pnax.params.points = 1001;
pnax.params.power = -30;
pnax.params.averages = 10000;
pnax.params.ifbandwidth = 100e3;
pnax.params.cwfreq=peakFreq;
pnax.ClearChannelAverages(2);
pause(specWaitTime);

fspec = pnax.ReadAxis();
pnax.SetActiveTrace(3);
[data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();
pnax.SetActiveTrace(4);
[data_specS41A data_specS41P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
% plot(fspec,data_specS21A,'b',fspec,data_specS41A,'r')
% plot(fspec,data_specS21A);
plot(fspec,data_specS41A);
subplot(2,1,2);
% plot(fspec,data_specS21P);
plot(fspec,data_specS41P);



