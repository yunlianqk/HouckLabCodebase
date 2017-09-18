funclib.clear_local_variables()

addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')

%%
time = clock;
runDate = datestr(time,'mmddyy');

%% set up the twpa pump
twpagen.ModOff();
twpagen.freq = 8.265e9;
twpagen.power = 16.3; %20 dB external, splitter, power amp
twpagen.PowerOn();

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
% CM = [1 0 0; 0 1 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated 8/12 to include qubit effects on coupler  
% CM = [1 0 0; 0 1/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Changed the diagonal element for the right qubit  
% CM = [0.07512 0 0; 0 0.9198/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated left and right qubit diagonal elements at 9:30 am on 8/17/17 
% CM = [0.07512 -0.009225 -0.001525; -0.003587 0.4841 0.002462; 0.4181 -0.4286 2.2222];  % Alicia update from scans over the past few days. Up 8/17/17
% CM = [0.0743 -0.0143 -0.0015; -0.0010 0.4759 -0.0069; 0.4181 -0.4286 2.2815];   %Alicia update from scans over past few days 9/15/17
% CM = [0.0743 -0.0143 -0.0015; -0.008 0.4759 -0.0069; 0.4181 -0.4286 2.2815];  %temporary junk
CM = [0.0743 -0.004 -0.0164; -0.0061 0.4759 0.0118; 0.4181 -0.4286 2.2815];  %Alicia update with new sign convention 9/15/17

% f0 = [0; 0; -0.05]; % iteration2
% f0 = [0; -0.2; -0.1083]; % updated 08/22/17 at 6:30 pm
f0 = [0; -0.30237; -0.035899]; % updated 09/15/17 at 5:30 pm
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

voltageCutoff = 3.5;

%% set up acquisitions
clear acquisitionPoints mp
tempdx = 0;

PNAXattenuation = 20;





% %%%%%%% LL ready to go
% tempdx = tempdx+1;
% mp = {};
% mp.name = ['leftQubit_leftQubitSweep']; 
% fstart=[leftQubitMax (rightQubitMax + rightQubitResonance)/2 0.0];
% fstop=[0.25 (rightQubitMax + rightQubitResonance)/2 0.0];
% fsteps=125;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% mp.cwpower = -50 + PNAXattenuation;
% mp.specpower = -45;
% mp.transWaitTime = 10;
% mp.specWaitTime = 80;
% mp.startfreq = 3.5e9; % mp.startfreq = 4e9;
% mp.stopfreq = 8.0e9; % mp.stopfreq = 7.5e9;
% mp.points = 2001; %spec points
% mp.whichcavity = 1; %2 for right/upper, and 1 for left/lower
% acquisitionPoints(tempdx) = mp;

%%%%CL 
tempdx = tempdx+1;
mp = {};
mp.name = ['leftQubit_couplerSweep_CMconfirm']; 
fstart=[(leftQubitMax+leftQubitResonance)/2 (rightQubitMax + rightQubitResonance)/2 -1.0];
fstop=[(leftQubitMax+leftQubitResonance)/2 (rightQubitMax + rightQubitResonance)/2 1.0];
fsteps=8;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
mp.vtraj = vtraj;
mp.cwpower = -50 + PNAXattenuation;
% mp.specpower = -40;
mp.specpower = -45;
mp.transWaitTime = 10;
mp.specWaitTime = 25;
mp.startfreq = 3.5e9;
mp.stopfreq = 8.0e9;
mp.points = 2001; %spec points
mp.whichcavity = 1; %2 for right/upper, and 1 for left/lower
acquisitionPoints(tempdx) = mp;

%%%%RL
tempdx = tempdx+1;
mp = {};
mp.name = ['leftQubit_rightQubitSweep_CMconfirm']; 
fstart=[leftQubitMax -0.6 0.0];
fstop=[leftQubitMax 0.3 0.0];
fsteps=8;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
mp.vtraj = vtraj;
mp.cwpower = -50 + PNAXattenuation;
mp.specpower = -40;
mp.specpower = -45;
mp.transWaitTime = 10;
mp.specWaitTime = 50;
mp.startfreq = 3.5e9;
mp.stopfreq = 8.0e9;
mp.points = 2001; %spec points
mp.whichcavity = 1; %2 for right/upper, and 1 for left/lower
acquisitionPoints(tempdx) = mp;


% %%%%CR 
% tempdx = tempdx+1;
% mp = {};
% mp.name = ['rightQubit_couplerSweep_CMconfirm']; 
% fstart=[0 rightQubitResonance -1.0];
% fstop=[0 rightQubitResonance 1.0];
% fsteps=8;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% mp.cwpower = -50 + PNAXattenuation;
% % mp.specpower = -40;
% mp.specpower = -45;
% mp.transWaitTime = 5;
% mp.specWaitTime = 25;
% mp.startfreq = 3.5e9;
% mp.stopfreq = 8.0e9;
% mp.points = 2001; %spec points
% mp.whichcavity = 2; %2 for right/upper, and 1 for left/lower
% acquisitionPoints(tempdx) = mp;

% %%%%LR
% tempdx = tempdx+1;
% mp = {};
% mp.name = ['rightQubit_leftQubitSweep_CMconfirm']; 
% fstart=[leftQubitMax rightQubitResonance 0.0];
% fstop=[leftQubitMin rightQubitResonance 0.0];
% fsteps=8;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% mp.cwpower = -50 + PNAXattenuation;
% mp.specpower = -40;
% mp.specpower = -45;
% mp.transWaitTime = 5;
% mp.specWaitTime = 15;
% mp.startfreq = 3.5e9;
% mp.stopfreq = 8.0e9;
% mp.points = 2001; %spec points
% mp.whichcavity = 2; %2 for right/upper, and 1 for left/lower
% acquisitionPoints(tempdx) = mp;














% %%
% 
% % fstart=[0.0 -1.2 0.0];
% % fstop=[0.0 0.7 0.0];fsteps=180;
% % fstart=[leftQubitMax rightQubitResonance 0.0];
% % fstop=[leftQubitMin rightQubitResonance 0.0];fsteps=4;
% fstart=[0.25 -1.0 0.0];
% fstop=[0.25 0.0 0.0];
% fsteps=4;
% 
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% ftraj=fc.calculateFluxTrajectory(vtraj);
% fc.visualizeTrajectories(vtraj,ftraj);
% steps=fsteps;   

clear vstart vstop vtraj fstart fstop fsteps
%% Switch to spec channels and update settings

pnax.PowerOn();
pnax.TrigContinuous;
pnax.params=paramlib.pnax.spec();

pnax.SetActiveTrace(3);
pnax.TrigContinuous;

transpoints = 1201;

temp = size(acquisitionPoints);
numAcquisitions = temp(2);
for acq = 1:numAcquisitions
    %load the acquisition configuration
    config = acquisitionPoints(acq);
    
    whichcavity=config.whichcavity;
    
    transWaitTime = config.transWaitTime;
    specWaitTime = config.specWaitTime;
    
    vtraj = config.vtraj;
    ftraj=fc.calculateFluxTrajectory(vtraj);
    fstart = ftraj(:,1);
    fstop = ftraj(:,end);
    temp = size(ftraj);
    steps = temp(2);
    

    %% run scan
    clear transAmpLine transPhaseLine specAmpLine specPhaseLine
    clear transAmpData transPhaseData specAmpData specPhaseData
    clear peakFreqData
    transAmpData = zeros(steps,transpoints);
    transPhaseData = zeros(steps,transpoints);
    specAmpData = zeros(steps,config.points);
    specPhaseData = zeros(steps,config.points);
    time=clock;
    tic;
    for idx=1:steps %loop over the voltage points

        if idx==1
            time=clock;
            timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
            filename=['specAutoScan_' config.name '_' timestr];
%             if whichQubit == 2
%                 time=clock;
%                 timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
%                 filename=['specAutoScan_' config.name '_' timestr];
% %                 filename=['specAutoScan_rightQubit_' timestr];
%     %             filename=['specAutoScan_rightQubit_' ...
%     %                 num2str(time(1)) num2str(time(2)) num2str(time(3))...
%     %                 num2str(time(4)) num2str(time(5))];
%             else
%                 time=clock;
%                 timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
%                 filename=['specAutoScan_' config.name '_' timestr];
% %                 filename=['specAutoScan_leftQubit_' timestr];
%     %             filename=['specAutoScan_leftQubit_' ...
%     %                 num2str(time(1)) num2str(time(2)) num2str(time(3))...
%     %                 num2str(time(4)) num2str(time(5))];
%             end

            fc.currentVoltage=vtraj(:,2); %preramp yoko to get a better idea of the actual time that a scan will take
            tStart=tic;
            time=clock;
        end
        fc.currentVoltage=vtraj(:,idx);
        
        %%%%% switch to transmission 
        pnax.params=paramlib.pnax.trans();
        if config.whichcavity==1
            pnax.params.start = 5.75e9;
            pnax.params.stop = 5.87e9;
        else
            pnax.params.start = 5.87e9;
            pnax.params.stop = 5.95e9;
        end
        pnax.params.points = transpoints;
        pnax.params.power = -50 + PNAXattenuation;
        pnax.params.averages = 65536;
        pnax.params.ifbandwidth = 15e3;

        transCh1 = pnax.params; 
        
        %get transmission data
        pnax.SetActiveTrace(1)
        pnax.ClearChannelAverages(1);
        pause(transWaitTime);
        
        ftrans = pnax.ReadAxis();
        [transAmpLine transPhaseLine] = pnax.ReadAmpAndPhase();
        transAmpData(idx,:)=transAmpLine;
        transPhaseData(idx,:)=transPhaseLine;
        
%         %plot the found peak
%         figure(2);
%         plot(ftrans,data_transS21A,'b');
%         hold on; plotlib.vline(peakFreq); hold off
        
        %store the transmission params
        transFreqVector = ftrans;
        transparams.points=pnax.params.points;
        transparams.start=pnax.params.start;
        transparams.stop=pnax.params.stop;
        transparams.waitTime = transWaitTime;
        transparams.actualPower = pnax.params.power+PNAXattenuation;

        % fidx peak
        [peakVal,peakidx] = max(transAmpLine); peakFreq = transFreqVector(peakidx);
        peakFreqData(idx)=peakFreq;
        figure(665);
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

        
        
        
        
        
        
        %%%%%%%set spec parameters and new peak freq
        pnax.SetActiveTrace(3);
        
        pnax.params.cwpower = config.cwpower;
        pnax.params.specpower = config.specpower;
        
        pnax.params.start = config.startfreq;
        pnax.params.stop = config.stopfreq;
        
        specparams.cwfreq=peakFreq;
        pnax.params.cwfreq=peakFreq;
        
        pnax.params.points = 2001;
        % pnax.params.averages = 10000;
        pnax.params.averages = 65536;
        pnax.params.ifbandwidth = 250e3;
        
        pnax.ClearChannelAverages(2);
        pause(specWaitTime);

        %read the spec
        fspec = pnax.ReadAxis();
        specFreqVector = fspec;
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
        
        %file away the spec params
        specFreqVector = fspec;
        specparams.points=pnax.params.points;
        specparams.start = pnax.params.start;
        specparams.stop = pnax.params.stop;
        specparams.waitTime = specWaitTime;
        specparams.specpower = pnax.params.specpower;
        specparams.actualcwpower = pnax.params.cwpower+PNAXattenuation;


        if idx==1 && acq == 1
            deltaT=toc(tStart);
            estimatedTime=steps*deltaT*numAcquisitions;
            disp(['Estimated Time is '...
                num2str(estimatedTime/3600),' hrs, or '...
                num2str(estimatedTime/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(estimatedTime),'second'))]);
        end

        full_path_info = mfilename('fullpath');
        folder_breaks = regexp(full_path_info,'\');
        current_file_location = full_path_info(1:max(folder_breaks));
        AllFiles = funclib.TextSave(current_file_location);

    %     saveFolder = 'C:\Users\BFG\Documents\Mattias\tunableDimer\SpecScans_081617\';
        saveFolder = ['Z:\Mattias\Data\tunableDimer\SpecScans_' runDate '\'];
        if exist(saveFolder)==0
            mkdir(saveFolder);
        end
        if ~mod(idx,20)
            save([saveFolder filename '.mat'],...
                'fc','steps',...
                'transWaitTime','transparams','specWaitTime','specparams',...
                'transAmpData','transPhaseData','specAmpData','specPhaseData',...
                'specFreqVector','transFreqVector','specWaitTime','transWaitTime','vtraj', 'ftraj', 'AllFiles', 'peakFreqData');
        end


    end

    toc
    beep
    save([saveFolder filename '.mat'],...
        'fc','steps',...
        'transWaitTime','transparams','specWaitTime','specparams',...
        'transAmpData','transPhaseData','specAmpData','specPhaseData',...
        'specFreqVector','transFreqVector','vtraj', 'ftraj', 'AllFiles', 'peakFreqData');

    title(filename)
    savefig([saveFolder filename '.fig']);

    % 



    %alternate save method
    % currFilePath = 'C:\Users\BFG\Documents\HouckLabMeasurementCode\Mattias\tunableDimer\specScan.m';
    currFilePath = mfilename('fullpath');
    savePath = [saveFolder filename 'AK' '.mat'];
    % funclib.save_all(savePath);
    funclib.save_all(savePath, currFilePath);
end %end loop over all acquisitions


fc.currentVoltage=[0 0 0];


