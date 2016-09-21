%% Update and read transmission channel
pnax.SetActiveTrace(1);
transWaitTime=10;
pnax.params.start = 10.16e9;
pnax.params.stop = 10.17e9;
pnax.params.points = 1001;
pnax.params.power = 5;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
pause(transWaitTime);
ftrans = pnax.ReadAxis();
pnax.SetActiveTrace(1);
[data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();

figure();
subplot(2,1,1);
plot(ftrans,data_transS21A,'r');
subplot(2,1,2);
plot(ftrans,data_transS21P,'r');

transFreqVector = ftrans;
transparams.points=pnax.params.points;
transparams.start=pnax.params.start;
transparams.stop=pnax.params.stop;

%% Compensate Electrical Delay - needs to be updated
pnax.SetActiveTrace(1);
pnax.CompensateElectricalDelay()


%% find cavity peak frequency and optimal phase contrast bias point
transAmpLine = data_transS21A; transPhaseLine=data_transS21P;
% transAmpLine = data_transS41A; transPhaseLine=data_transS41P;
% choose max for a transmission peak and min for a reflection dip!
% [peakVal,peakInd] = max(transAmpLine); peakFreq = ftrans(peakInd);
[peakVal,peakInd] = min(transAmpLine); peakFreq = ftrans(peakInd);
figure(651);
subplot(2,1,1);plot(ftrans/1e9,transAmpLine);
title('Transmission [MLOG]')
hold on; plotlib.vline(peakFreq/1e9); hold off
subplot(2,1,2);plot(ftrans/1e9,transPhaseLine);
hold on; plotlib.vline(peakFreq/1e9); hold off
title('Transmission [Unwrapped phase]')

%% Switch to spec channels and update settings
pnax.SetActiveTrace(3);
specWaitTime = 1;
pnax.params.cwpower = 5;
pnax.params.start =  4.6e9;
pnax.params.stop = 4.61e9;
% pnax.params.start =  3.2e9;
% pnax.params.stop = 3.4e9;
pnax.params.points = 5001;
% pnax.params.points = 1001;
pnax.params.power = 10;
pnax.params.averages = 10000;
pnax.params.ifbandwidth = 100e3;
pnax.params.cwfreq=peakFreq;
pnax.ClearChannelAverages(2);
pause(specWaitTime);

fspec = pnax.ReadAxis();
pnax.SetActiveTrace(3);
[data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
plot(fspec,data_specS21A);
subplot(2,1,2);
plot(fspec,data_specS21P);


