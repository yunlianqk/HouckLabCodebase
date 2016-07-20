%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.0001;yoko1.rampinterval=.01;
yoko2.rampstep=.0001;yoko2.rampinterval=.01;
yoko3.rampstep=.0001;yoko3.rampinterval=.01;
% CM = [1 0 0;  0 1 0; 0 0 1;]
% f0 = [0; 0; 0;];

CM = [.0845 0 0;  0 0.5597 0; .5659 -.4699 2.3068;]
f0 = [0; -.1975; -.348;];
fc=fluxController(CM,f0);

%% Generate flux trajectory (start flux, stop flux, steps)
clear vtraj ftraj
% fstart=[-.0533 -.5 0];fstop=[-.0533 .5 0];fsteps=201;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% ftraj=fc.calculateFluxTrajectory(vtraj);
% fc.visualizeTrajectories(vtraj,ftraj);
%% Generate voltage trajectory (start voltage, stop voltage, steps)
clear vtraj ftraj
vtraj=fc.generateTrajectory([-.7101 -3 .3969],[-.7101 3 .3969],1001);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);

%% Update and read transmission channel
pnax.SetActiveTrace(1);
transWaitTime=10;
pnax.params.start = 5.78e9;
pnax.params.stop = 5.85e9;
pnax.params.points = 1001;
pnax.params.power = -50;
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
% plot(ftrans,data_transS21A,'r');
% plot(ftrans,data_transS41A,'r');
subplot(2,1,2);
plot(ftrans,data_transS21P,'b',ftrans,data_transS41P,'r');
% plot(ftrans,data_transS21P,'r');
% plot(ftrans,data_transS41P,'r');

transFreqVector = ftrans;
transparams.points=pnax.params.points;
transparams.start=pnax.params.start;
transparams.stop=pnax.params.stop;
%% Switch to spec channels and update settings
pnax.SetActiveTrace(3);
specWaitTime = 30;
pnax.params.cwpower = -50;
pnax.params.start = 6e9;
pnax.params.stop = 8.5e9;
pnax.params.points = 3001;
pnax.params.power = -45;
pnax.params.averages = 10000;
pnax.params.ifbandwidth = 100e3;
pnax.params.cwfreq=peakFreq;
pnax.ClearChannelAverages(2);
pause(specWaitTime);

fspec = pnax.ReadAxis();
pnax.SetActiveTrace(3);
[data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();
% pnax.SetActiveTrace(4);
% [data_specS41A data_specS41P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
plot(fspec,data_specS21A);
% plot(fspec,data_specS41A);
subplot(2,1,2);
plot(fspec,data_specS21P);
% plot(fspec,data_specS41P);

specFreqVector = fspec;S
specparams.points=pnax.params.points;
specparams.start = pnax.params.start;
specparams.stop = pnax.params.stop;

%% run scan

clear transAmpLine transPhaseLine specAmpLine specPhaseLine
clear transAmpData transPhaseData specAmpData specPhaseData
clear peakFreqData
steps=size(vtraj,2);
transAmpData = zeros(steps,transparams.points);
transPhaseData = zeros(steps,transparams.points);
specAmpData = zeros(steps,specparams.points);
specPhaseData = zeros(steps,specparams.points);
time=clock;
tic;
for ind=1:steps
%     ramp flux
    fc.currentVoltage=vtraj(:,ind);

    % switch to transmission 
    pnax.SetActiveTrace(1)
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    pnax.SetActiveTrace(1);
%     pnax.SetActiveTrace(2);
    [transAmpLine transPhaseLine] = pnax.ReadAmpAndPhase();
    transAmpData(ind,:)=transAmpLine;
    transPhaseData(ind,:)=transPhaseLine;
    
    % find peak
    [peakVal,peakInd] = max(transAmpLine); peakFreq = transFreqVector(peakInd);
    peakFreqData(ind)=peakFreq;
    figure(662);
    subplot(2,2,1)
    imagesc([transparams.start transparams.stop]/1e9,[1 ind],transAmpData(1:ind,:))
    title('transmission amplitude')
    subplot(2,2,2)
    imagesc([transparams.start transparams.stop]/1e9,[1 ind],transPhaseData(1:ind,:))
    title('transmission unwrapped phase')
    
    %update spec parameters with new peak
    pnax.SetActiveTrace(3);
    specparams.cwfreq=peakFreq;
    pnax.params.cwfreq=peakFreq;
    pnax.ClearChannelAverages(2);
    pause(specWaitTime);
    pnax.SetActiveTrace(3);
%     pnax.SetActiveTrace(4);
    [specAmpLine specPhaseLine] = pnax.ReadAmpAndPhase();
    specAmpData(ind,:)=specAmpLine;
    specPhaseData(ind,:)=specPhaseLine;
    subplot(2,2,3)
    imagesc([specparams.start specparams.stop]/1e9,[1 ind],specAmpData(1:ind,:))
    title('spec amp data')
    subplot(2,2,4)
    imagesc([specparams.start specparams.stop]/1e9,[1 ind],specPhaseData(1:ind,:))
    title('spec phase data')
    ind
    if ~mod(ind,20)
        save([dataDirectory 'JJR_specAutoScan' ...
            num2str(time(1)) num2str(time(2)) num2str(time(3))...
            num2str(time(4)) num2str(time(5)) '.mat'],...
            'yoko1','yoko2','yoko3','CM','f0','fc','ftraj','vtraj',...
            'transWaitTime','transparams','specWaitTime','specparams',...
            'transAmpData','transPhaseData','specAmpData','specPhaseData',...
            'peakFreqData');
    end

    
end

toc
beep
save([dataDirectory 'JJR_specAutoScan' ...
            num2str(time(1)) num2str(time(2)) num2str(time(3))...
            num2str(time(4)) num2str(time(5)) '.mat'],...
            'yoko1','yoko2','yoko3','CM','f0','fc','ftraj','vtraj',...
            'transWaitTime','transparams','specWaitTime','specparams',...
            'transAmpData','transPhaseData','specAmpData','specPhaseData',...
            'peakFreqData');

fc.currentVoltage=[0 0 0];