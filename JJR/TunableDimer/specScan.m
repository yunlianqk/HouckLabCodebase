%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.0001;yoko1.rampinterval=.1;
yoko2.rampstep=.0001;yoko2.rampinterval=.1;
yoko3.rampstep=.0001;yoko3.rampinterval=.1;
% CM = [1 0 0;  0 1 0; 0 0 1;]
% f0 = [0; 0; 0;];

CM = [.0845 0 0;  0 0.5597 0; .5659 -.4699 2.3068;]
f0 = [0; -.1975; -.348;];
fc=fluxController(CM,f0);

%% Generate flux trajectory (start flux, stop flux, steps)
clear vtraj ftraj
fstart=[0 -.7 0];fstop=[0 .7 0];fsteps=701;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);

%% Update and read transmission channel
pnax.SetActiveTrace(1);
transWaitTime=10;
pnax.params.start = 5.85e9;
pnax.params.stop = 5.91e9;
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
% plot(ftrans,data_transS21A,'b',ftrans,data_transS41A,'r');
plot(ftrans,data_transS41A,'r');
subplot(2,1,2);
% plot(ftrans,data_transS21P,'b',ftrans,data_transS41P,'r');
plot(ftrans,data_transS41P,'r');

transFreqVector = ftrans;
transparams.points=pnax.params.points;
transparams.start=pnax.params.start;
transparams.stop=pnax.params.stop;
%% Switch to spec channels and update settings
pnax.SetActiveTrace(3);
specWaitTime = 60;
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
% pnax.SetActiveTrace(3);
% [data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();
pnax.SetActiveTrace(4);
[data_specS41A data_specS41P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
plot(fspec,data_specS41A);
subplot(2,1,2);
plot(fspec,data_specS41P);

specFreqVector = fspec;
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
    pnax.SetActiveTrace(2);
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
    pnax.SetActiveTrace(4);
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
        save(['JJR_specAutoScan' ...
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
        
        
%%
% %% set up s41 trans
% transWaitTime=5;
% transparams.start = 5.85e9;
% transparams.stop = 5.95e9;
% transparams.points =1001;
% transparams.power = -40;
% transparams.averages = 65536;
% transparams.ifbandwidth = 10e3;
% transparams.trace = 1;
% transparams.meastype = 'S21';
% transparams.format = 'MLOG';
% S41transparams=transparams;
% S41transparams.trace=5;
% S41transparams.meastype='S41';
% S41transparams.format = 'MLOG';
% pnax.S41transparams = S41transparams;
% pnax.SetActiveTrace(5);pnax.SetS41TransParams();
% transFreqVector=pnax.GetAxis();

% %% set up S41 spec
% specWaitTime = 30;
% specparams.cwpower = -40;
% specparams.start = 6e9;
% specparams.stop = 10e9;
% specparams.points = 6001;
% specparams.power = -30;
% specparams.averages = 10000;
% specparams.ifbandwidth = 100e3;
% specparams.cwfreq=peakFreq;
% specparams.trace=3;
% specparams.meastype='S21';
% specparams.format='MLOG';
% S41specparams=specparams;
% S41specparams.trace=7;
% S41specparams.meastype='S41';
% S41specparams.format='MLOG';
% pnax.S41specparams=S41specparams;
% pnax.SetActiveTrace(7);pnax.SetS41SpecParams();
% specFreqVector=pnax.GetAxis();

%     --------------
% 
%     %update spec parameters with new peak
%     specparams.cwfreq=peakFreq;
%     S41specparams=specparams;
%     pnax.S41specparams=S41specparams;
%     pnax.SetActiveTrace(7);pnax.SetS41SpecParams();pnax.SetActiveTrace(7);
%     pnax.ClearChannelAverages(pnax.S41specchannel);
%     pause(specWaitTime);
%     specAmpLine=pnax.Read();
%     pnax.SetActiveTrace(8);
%     specPhaseLine=pnax.Read();
%     specAmpData(ind,:)=specAmpLine;
%     specPhaseData(ind,:)=specPhaseLine;
%     subplot(2,2,3)
%     imagesc([specparams.start specparams.stop]/1e9,[1 ind],specAmpData(1:ind,:))
%     title('spec amp data')
%     subplot(2,2,4)
%     imagesc([specparams.start specparams.stop]/1e9,[1 ind],specPhaseData(1:ind,:))
%     title('spec phase data')
%     ind
%     if ~mod(ind,20)
%         save(['JJR_specAutoScan' ...
%             num2str(time(1)) num2str(time(2)) num2str(time(3))...
%             num2str(time(4)) num2str(time(5)) '.mat'],...
%             'yoko1','yoko2','yoko3','CM','f0','fc','ftraj','vtraj',...
%             'transWaitTime','transparams','specWaitTime','specparams',...
%             'transAmpData','transPhaseData','specAmpData','specPhaseData',...
%             'peakFreqData');
%     end
