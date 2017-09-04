
funclib.clear_local_variables()

addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer');

%%
time = clock;
runDate = datestr(time,'mmddyy');

%%
% %% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.002;yoko1.rampinterval=.01;
yoko2.rampstep=.002;yoko2.rampinterval=.01;
yoko3.rampstep=.002;yoko3.rampinterval=.01;

% CM = [1 0 0; 0 1 0; 0 0 1];  %starter Matrix
% CM = [1 0 0; 0 1 0; 1/2.5 60/136 1/0.45];  %iteration3
% CM = [1 0 0; 0 1 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated 8/12 to include qubit effects on coupler
% CM = [1 0 0; 0 1/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Changed the diagonal element for the right qubit
% CM = [0.07512 0 0; 0 0.9198/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated left and right qubit diagonal elements at 9:30 am on 8/17/17
CM = [0.07512 -0.009225 -0.001525; -0.003587 0.4841 0.002462; 0.4181 -0.4286 2.2222];  % Alicia update from scans over the past few days. Up 8/17/17


% f0 = [0; -0.2; -0.25]; % updated 08/17/17 at 12 pm
% f0 = [0; -0.2; -0.05]; % updated 08/17/17 at 12 pm
f0 = [0; -0.2; -0.1083]; % updated 08/22/17 at 6:30 pm
fc=fluxController(CM,f0);
fc2 = fluxController2;
EcLeft = 298e6;
EcRight = 298e6;
EjSumLeft = 25.420e9;
EjSumRight = 29.342e9;
fc2.leftQubitFluxToFreqFunc = @(x) sqrt(8.*EcLeft.*EjSumLeft.*abs(cos(pi.*x)))-EcLeft;
fc2.rightQubitFluxToFreqFunc = @(x) sqrt(8.*EcRight.*EjSumRight.*abs(cos(pi.*x)))-EcRight;

% added these as of 08/17/17
rightQubitMin=-0.48;
rightQubitResonance=-0.3;
rightQubitMax=0;

leftQubitMin=0.11;
leftQubitResonance=-0.088;
leftQubitMax=-0.22;

couplerMinJ=0.44;
couplerMaxJ=0; 

%% set up acquisitions
clear acquisitionPoints m
tempdx = 0;



tempdx = tempdx+1;
mp = {};

% fstart=[leftQubitMin rightQubitResonance+0.2 0.0];
% fstop=[leftQubitMin rightQubitMin 0.0];fsteps=15;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);


fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitMin rightQubitMin+0.025 0.0];fsteps=10;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);

voltageCutoff = 3.5;

if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end

mp.name = ['maxJ_SDDO_LQCsweep_upperPeak_specScan_']; %left qubit resonant
mp.vtraj = vtraj;
mp.steps = fsteps;
mp.whichQubit = 1;
mp.specStartFreq = 2.0e9;
mp.specStopFreq = 5.5e9;
mp.specNumPoints = 1201;
mp.transNumPoints = 1201;
mp.power = -50;
mp.averages = 65536;
mp.ifbandwidth = 15e3;
mp.cwpower = -50;
mp.transWaitTime = 10;
mp.specWaitTime = 60;
acquisitionPoints(tempdx) = mp;


tic; time=fix(clock);
temp = size(acquisitionPoints);
numAcquisitions = temp(2);

for acq = 1:numAcquisitions
    m = acquisitionPoints(acq); %pull the acquisition settings
    
    fc.currentVoltage = m.vtraj(:,1);
    
    pnax.PowerOn();
    pnax.TrigContinuous;

    pnax.params=paramlib.pnax.trans();
    pnax.SetActiveTrace(1);
    
    
    if m.whichQubit==1
        pnax.params.start = 5.87e9;
        pnax.params.stop = 5.95e9;
    else
        pnax.params.start = 5.85e9;
        pnax.params.stop = 5.95e9;
    end
    
    pnax.params.points = m.transNumPoints;
    pnax.params.power = m.power;
    pnax.params.averages = m.averages;
    pnax.params.ifbandwidth = m.ifbandwidth;
    
    transCh1 = pnax.params;
    
    pnax.AvgClear(1);
    pause(m.transWaitTime);
    ftrans = pnax.ReadAxis();
    pnax.SetActiveTrace(1);
    [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
    
    [peakVal,peakidx] = max(data_transS21A); peakFreq = ftrans(peakidx);
    
    figure(2);
    plot(ftrans,data_transS21A,'b');
    hold on; plotlib.vline(peakFreq); hold off
    
    m.transFreqVector = ftrans;
    transparams.points=pnax.params.points;
    transparams.start=pnax.params.start;
    transparams.stop=pnax.params.stop;
    
    
    %% Switch to spec channels and update settings
    
    pnax.TrigContinuous;
    pnax.params=paramlib.pnax.spec();
    
    pnax.SetActiveTrace(3);

    
    %% run scan
    
    clear transAmpLine transPhaseLine specAmpLine specPhaseLine
    clear transAmpData transPhaseData specAmpData specPhaseData
    clear peakFreqData
    transAmpData = zeros(m.steps,m.transNumPoints);
    transPhaseData = zeros(m.steps,m.transNumPoints);
    specAmpData = zeros(m.steps,m.transNumPoints);
    specPhaseData = zeros(m.steps,m.transNumPoints);
    time=clock;
    tic;
    for idx=1:m.steps
        
        if idx==1
            tStart=tic;
            time=clock;
            timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
            m.filename=[m.name '_'  timestr];
        end
        fc.currentVoltage=m.vtraj(:,idx);
        % switch to transmission
        pnax.SetActiveTrace(1)
        pnax.AvgClear(1);
        pause(m.transWaitTime);
        [transAmpLine transPhaseLine] = pnax.ReadAmpAndPhase();
        transAmpData(idx,:)=transAmpLine;
        transPhaseData(idx,:)=transPhaseLine;
        
        % fidx peak
        [peakVal,peakidx] = max(transAmpLine); peakFreq = m.transFreqVector(peakidx);
        peakFreqData(idx)=peakFreq;
        figure(662);
        subplot(3,2,1)
        imagesc(m.transFreqVector/1e9,[1:idx],transAmpData(1:idx,:))
        xlabel('Transmission Frequency [GHz]');
        ylabel('steps');
        title('transmission amplitude')
        subplot(3,2,2)
        imagesc(m.transFreqVector/1e9,[1:idx],transPhaseData(1:idx,:))
        xlabel('Transmission Frequency [GHz]');
        ylabel('steps');
        title('transmission unwrapped phase');
        
        %update spec parameters with new peak
        pnax.SetActiveTrace(3);
        
        pnax.params.points = m.specNumPoints;
        pnax.params.start =  mp.specStartFreq;
        pnax.params.stop =  mp.specStopFreq;
        m.specFreqVector = pnax.ReadAxis();
        
        
        pnax.params.cwfreq=peakFreq;
        pnax.AvgClear(2);
        pause(m.specWaitTime);
        
        pnax.SetActiveTrace(3);
        
        [specAmpLine specPhaseLine] = pnax.ReadAmpAndPhase();
        specAmpData(idx,:)=specAmpLine;
        specPhaseData(idx,:)=specPhaseLine;
        subplot(3,2,3)
        imagesc(m.specFreqVector/1e9,[1:idx],specAmpData(1:idx,:))
        xlabel('Spec Frequency [GHz]');
        ylabel('steps');
        title([m.filename ', Amp']);
        subplot(3,2,4)
        imagesc(m.specFreqVector/1e9,[1:idx],specPhaseData(1:idx,:))
        xlabel('Spec Frequency [GHz]');
        ylabel('steps');
        title([m.filename, ', Phase']);
        
        subplot(3,2,5);
        plot(m.specFreqVector/1e9,specAmpData(idx,:))
        
        subplot(3,2,6);
        plot(m.specFreqVector/1e9,specAmpData(idx,:))
        
        if idx==1
            deltaT=toc(tStart);
            estimatedTime=m.steps*deltaT*numAcquisitions;
            disp(['Estimated Time is '...
                num2str(estimatedTime/3600),' hrs, or '...
                num2str(estimatedTime/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(estimatedTime),'second'))]);
        end
        
        
        
    end
    
    toc
    beep
    saveFolder = ['Z:\Mattias\Data\tunableDimer\SpecScans_' runDate '\'];
    isFolder = exist(saveFolder);
    if isFolder == 0
        mkdir(saveFolder)
    end
    
    save([saveFolder m.filename '.mat'],...
        'fc','m',...
        'transAmpData','transPhaseData','specAmpData','specPhaseData');
    title(m.filename)
    savefig([saveFolder m.filename '.fig']);
    
end % loop over acquisitions


fc.currentVoltage=[0 0 0];
