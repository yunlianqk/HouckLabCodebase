%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.002;yoko1.rampinterval=.01;
yoko2.rampstep=.002;yoko2.rampinterval=.01;
yoko3.rampstep=.002;yoko3.rampinterval=.01;


% these are leftover from before
% nla = 3.5; %new attenuation of left line
% nra = 2.9; %new attenuation of right line
% nca = 1.075; %new attenuation of coupler line
% cal_MAT = [.0845/nla      -.00037/nra     -.011/nca;     -.0034/nla      0.5597/nra      .0117/nca;      0.1535   -0.1765   2.1810];  %best guess from calibrated bottom row and old matrix, 6-21-17
% CM = cal_MAT;

% CM = [1 0 0; 0 1 0; 0 0 1];  %starter Matrix
% CM = [1 0 0; 0 1 0; 1/2.5 60/136 1/0.45];  %iteration3
CM = [1 0 0; 0 1 0; 120/(7*41) 120/(7*40) 1/0.45];  % Updated 8/12 to include qubit effects on coupler  

f0 = [0; 0; -0.05]; % iteration2
fc=fluxController(CM,f0);

fc2 = fluxController2;
EcLeft = 298e6;
EcRight = 298e6;
EjSumLeft = 25.420e9;
EjSumRight = 29.342e9;
fc2.leftQubitFluxToFreqFunc = @(x) sqrt(8.*EcLeft.*EjSumLeft.*abs(cos(pi.*x)))-EcLeft;
fc2.rightQubitFluxToFreqFunc = @(x) sqrt(8.*EcRight.*EjSumRight.*abs(cos(pi.*x)))-EcRight;


%%

fstart=[-3.5 0.0 0.0];
fstop=[-2.5 0.0 0.0];fsteps=50;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);
steps=fsteps;        
%%
fc.currentVoltage=vtraj(:,1);
%%
pnax.PowerOn();
pnax.TrigContinuous;
%% Update and read transmission channel

whichQubit=1;

pnax.params=paramlib.pnax.trans();
pnax.SetActiveTrace(1);
transWaitTime=45;

if whichQubit==1
    pnax.params.start = 5.75e9;
    pnax.params.stop = 5.85e9;
else
    pnax.params.start = 5.87e9;
    pnax.params.stop = 5.95e9;
end

pnax.params.points = 1201;
pnax.params.power = -50;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 15e3;

transCh1 = pnax.params; 

pnax.ClearChannelAverages(1);
pause(transWaitTime);
ftrans = pnax.ReadAxis();
pnax.SetActiveTrace(1);
[data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();

[peakVal,peakidx] = max(data_transS21A); peakFreq = ftrans(peakidx);

figure(2);
plot(ftrans,data_transS21A,'b');
hold on; plotlib.vline(peakFreq); hold off

transFreqVector = ftrans;
transparams.points=pnax.params.points;
transparams.start=pnax.params.start;
transparams.stop=pnax.params.stop;


%% Switch to spec channels and update settings

powerVec=linspace(-40,-20,3);
for pdx = 1:length(powerVec)

pnax.TrigContinuous;
pnax.params=paramlib.pnax.spec();

pnax.SetActiveTrace(3);
pnax.TrigContinuous;
specWaitTime = 25;
pnax.params.cwpower = -50;

if whichQubit==1
    pnax.params.start = 5.8e9;
    pnax.params.stop = 8.5e9;
else
    pnax.params.start = 3.5e9;
    pnax.params.stop = 5.88e9;
end


pnax.params.points = 2001;
pnax.params.specpower = powerVec(pdx);
pnax.params.averages = 10000;
pnax.params.ifbandwidth = 250e3;
pnax.params.cwfreq=peakFreq;

specCh1 = pnax.params;

pnax.ClearChannelAverages(2);
pause(specWaitTime);


fspec = pnax.ReadAxis();
pnax.SetActiveTrace(3);
[data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();

figure(909);
subplot(2,1,1);
plot(fspec/1e9,data_specS21A);
title('S21A');
subplot(2,1,2);
plot(fspec/1e9,data_specS21P);
title('S21P');

specFreqVector = fspec;
specparams.points=pnax.params.points;
specparams.start = pnax.params.start;
specparams.stop = pnax.params.stop;

%% run scan
specWaitTime = 300;
clear transAmpLine transPhaseLine specAmpLine specPhaseLine
clear transAmpData transPhaseData specAmpData specPhaseData
clear peakFreqData
transAmpData = zeros(steps,transparams.points);
transPhaseData = zeros(steps,transparams.points);
specAmpData = zeros(steps,specparams.points);
specPhaseData = zeros(steps,specparams.points);
time=clock;
tic;
for idx=1:steps

    if idx==1
        filename=['specAutoScan_leftQubit_power' num2str(powerVec(pdx)) '_' ...
            num2str(time(1)) num2str(time(2)) num2str(time(3))...
            num2str(time(4)) num2str(time(5))];

        tStart=tic;
        time=clock;
    end
    fc.currentVoltage=vtraj(:,idx);
    % switch to transmission 
    pnax.SetActiveTrace(1)
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    [transAmpLine transPhaseLine] = pnax.ReadAmpAndPhase();
    transAmpData(idx,:)=transAmpLine;
    transPhaseData(idx,:)=transPhaseLine;
    
    % fidx peak
    [peakVal,peakidx] = max(transAmpLine); peakFreq = transFreqVector(peakidx);
    peakFreqData(idx)=peakFreq;
    figure(662);
    subplot(3,2,1)
    imagesc(transFreqVector/1e9,[1:idx],transAmpData(1:idx,:))
    xlabel('Transmission Frequency [GHz]');
    ylabel('steps');
    title('transmission amplitude')
    subplot(3,2,2)
    imagesc(transFreqVector/1e9,[1:idx],transPhaseData(1:idx,:))
    xlabel('Transmission Frequency [GHz]');
    ylabel('steps');
    title('transmission unwrapped phase');
    
    %update spec parameters with new peak
    pnax.SetActiveTrace(3);
    specparams.cwfreq=peakFreq;
    pnax.params.cwfreq=peakFreq;
    pnax.ClearChannelAverages(2);
    pause(specWaitTime);

    pnax.SetActiveTrace(3);

    [specAmpLine specPhaseLine] = pnax.ReadAmpAndPhase();
    specAmpData(idx,:)=specAmpLine;
    specPhaseData(idx,:)=specPhaseLine;
    subplot(3,2,3)
    imagesc(specFreqVector/1e9,[1:idx],specAmpData(1:idx,:))
    xlabel('Spec Frequency [GHz]');
    ylabel('steps');
    title([filename ', Amp']);
    subplot(3,2,4)
    imagesc(specFreqVector/1e9,[1:idx],specPhaseData(1:idx,:))
    xlabel('Spec Frequency [GHz]');
    ylabel('steps');
    title([filename, ', Phase']);
    
    subplot(3,2,5);
    plot(specFreqVector/1e9,specAmpData(idx,:))
    
    subplot(3,2,6);
    plot(specFreqVector/1e9,specAmpData(idx,:))
    
    if idx==1
        deltaT=toc(tStart);
        estimatedTime=steps*deltaT*length(powerVec);
        disp(['Estimated Time is '...
            num2str(estimatedTime/3600),' hrs, or '...
            num2str(estimatedTime/60),' min']);
        disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
            round(estimatedTime),'second'))]);
    end
    
    saveFolder = 'C:\Users\BFG\Documents\Mattias\tunableDimer\SpecScans_081217\';
    if exist(saveFolder)==0
        mkdir(saveFolder);
    end
    if ~mod(idx,20)
        save([saveFolder filename '.mat'],...
            'fc','steps',...
            'transWaitTime','transparams','specWaitTime','specparams',...
            'transAmpData','transPhaseData','specAmpData','specPhaseData',...
            'specFreqVector','transFreqVector','specWaitTime','transWaitTime');
    end
    
    
end

toc
beep
save([saveFolder filename '.mat'],...
    'fc','steps',...
    'transWaitTime','transparams','specWaitTime','specparams',...
    'transAmpData','transPhaseData','specAmpData','specPhaseData',...
    'specFreqVector','transFreqVector');

title(filename)
savefig([saveFolder filename '.fig']);

end
fc.currentVoltage=[0 0 0];