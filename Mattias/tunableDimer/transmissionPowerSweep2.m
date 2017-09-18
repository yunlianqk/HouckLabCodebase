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
% twpagen.PowerOff();

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
CM = [0.07512 -0.009225 -0.001525; -0.003587 0.4841 0.002462; 0.4181 -0.4286 2.2222];


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

couplerMinJ=0.3592;
couplerMaxJ=0;

% %% test trajectory
% % fstart=[leftQubitMin 0.0 -1.0];
% % fstop=[leftQubitMin 0.0 1.0];fsteps=20;
% % fstart=[leftQubitMin -1.0 0.0];
% % fstop=[leftQubitMin 1. 0.0];fsteps=20;
% % fstart=[leftQubitMax 0 0.0];
% % fstop=[leftQubitMin 0 0.0];fsteps=20;
%
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
%
% voltageCutoff = 3.5;
%
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
%
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% ftraj=fc.calculateFluxTrajectory(vtraj);
% fc.visualizeTrajectories(vtraj,ftraj);

%% drive power settings
pnax.params = paramlib.pnax.trans();
PNAXattenuation = 40;

voltageCutoff = 3.5;

clear acquisitionPoints mp
tempdx = 0;

fstart=[leftQubitMin rightQubitMin couplerMinJ];
fstop=[leftQubitMin rightQubitMin couplerMaxJ];
fsteps=6;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
for ldx = 1:fsteps
    % for ldx = [1, 3, 5]
    tempdx = tempdx+1;
    mp = {};
    mp.name = ['JSweep_detuned_DDDO_powerSweep_vtraj' num2str(ldx)];
    mp.voltagePoint = vtraj(:,ldx);
    mp.startPower = -70 + PNAXattenuation;
    mp.stopPower = -30 + PNAXattenuation;
    mp.powerNumPoints = 200;
    mp.powerVec = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
    mp.startFreq = 5.78e9;
    mp.stopFreq = 5.95e9;
    mp.freqNumPoints = 2210;
    mp.waitTime = 20;
    acquisitionPoints(tempdx) = mp;
end

fstart=[leftQubitResonance rightQubitResonance couplerMinJ];
fstop=[leftQubitResonance rightQubitResonance couplerMaxJ];
fsteps=6;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
for ldx = 1:fsteps
    % for ldx = [1, 3, 5]
    tempdx = tempdx+1;
    mp = {};
    mp.name = ['JSweep_resonance_DDDO_powerSweep_vtraj' num2str(ldx)];
    mp.voltagePoint = vtraj(:,ldx);
    mp.startPower = -70 + PNAXattenuation;
    mp.stopPower = -30 + PNAXattenuation;
    mp.powerNumPoints = 200;
    mp.powerVec = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
    mp.startFreq = 5.78e9;
    mp.stopFreq = 5.95e9;
    mp.freqNumPoints = 2210;
    mp.waitTime = 20;
    acquisitionPoints(tempdx) = mp;
end
%


%%
temp = size(acquisitionPoints);
numAcquisitions = temp(2);
for acq = 1:numAcquisitions
    m = acquisitionPoints(acq); %pull the acquisition settings
    
    powerVec = m.powerVec;
    fc.currentVoltage = m.voltagePoint;
    
    pnax.params.start = m.startFreq;
    pnax.params.stop = m.stopFreq;
    
    pnax.params.points = m.freqNumPoints;
    
    tic; time=fix(clock);
    points=pnax.params.points; freqvector=pnax.ReadAxis();
    z = zeros(length(powerVec),points); transS21AlongTrajectoryAmp=z; transS21AlongTrajectoryPhase=z; transS41AlongTrajectoryAmp=z; transS41AlongTrajectoryPhase=z;
    
    
    for pdx = 1:length(powerVec)
        %% Update and read transmission channel
        
        if pdx==1
            tStart=tic;
            time=clock;
            timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
            %         filename=['matrixCalibration_rightInput_' num2str(powerVec(pdx)-PNAXattenuation) 'wAtten_'  timestr];
            %                 filename=['matrixCalibration_leftInput_' num2str(powerVec(pdx)-PNAXattenuation) 'wAtten_'  timestr];
            filename=['pnaxPowerScan_leftInput_' m.name '_'  num2str(powerVec(pdx)-PNAXattenuation) 'wAtten_'  timestr];
            %                 filename=['matrixCalibration_rightInput_' config.name '_'  num2str(powerVec(pdx)-PNAXattenuation) 'wAtten_'  timestr];
        end
        
        pnax.SetActiveTrace(1);
        
        pnax.params.power = powerVec(pdx);
       
        pnax.params.averages = 15000;
        pnax.params.ifbandwidth = 10e3;
        pnax.AvgClear(1);
        ftrans = pnax.ReadAxis();    
               
        % measure S21 and S41
        pnax.SetActiveTrace(1);
        pnax.AvgClear(1);
        pause(m.waitTime);
        pnax.SetActiveTrace(1);
        [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase(); %right output
        pnax.SetActiveTrace(2);
        pause(1);
        [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase(); %left output
        
        transS21AlongTrajectoryAmp(pdx,:)=data_transS21A;
        transS21AlongTrajectoryPhase(pdx,:)=data_transS21P;
        transS41AlongTrajectoryAmp(pdx,:)=data_transS41A;
        transS41AlongTrajectoryPhase(pdx,:)=data_transS41P;
        
        f = figure(77);
        set(f, 'Position', [68 184 1531 926]);
        clf()
        p = uipanel('Parent',f,'BorderType','none');
        p.Title = filename;
        p.TitlePosition = 'centertop';
        p.FontSize = 12;
        p.FontWeight = 'bold';
        
        subplot(1,2,1,'Parent',p);
        imagesc(ftrans/1e9,powerVec(1:pdx),transS21AlongTrajectoryAmp(1:pdx,:)); title(filename); ylabel('Drive Power [dBm]');xlabel('Right Output Frequency [GHz]');
        colorbar(); set(gca,'YDir','normal');
        subplot(1,2,2,'Parent',p);
        imagesc(ftrans/1e9,powerVec(1:pdx),transS41AlongTrajectoryAmp(1:pdx,:)); title(''); ylabel('Drive Power [dBm]');xlabel('Left Output Frequency [GHz]');
        colorbar(); set(gca,'YDir','normal');
        
        if pdx==1 && acq == 1
            temp = size(acquisitionPoints);
            numAcqs = temp (2);
            
            deltaT=toc(tStart);
            estimatedTime=deltaT*length(powerVec)*numAcqs;
            disp(['Estimated Time is '...
                num2str(estimatedTime/3600),' hrs, or '...
                num2str(estimatedTime/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(estimatedTime),'second'))]);
        end
    end %end loop over flux steps
    
    %save all the relevant files
    full_path_info = mfilename('fullpath');
    folder_breaks = regexp(full_path_info,'\');
    current_file_location = full_path_info(1:max(folder_breaks));
    AllFiles = funclib.TextSave(current_file_location);
    
    pnaxSettings=pnax.params.toStruct();
    saveFolder = ['Z:\Mattias\Data\tunableDimer\PNAXPowerSweep_' runDate '\'];
    if exist(saveFolder)==0
        mkdir(saveFolder);
    end
    save([saveFolder filename '.mat'],...
        'CM','f0','fc','pnaxSettings','pnax','m','time',...
        'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase',...
        'transS41AlongTrajectoryAmp','transS41AlongTrajectoryPhase',...
        'AllFiles', 'acquisitionPoints')
    title(filename)
    savefig([saveFolder filename '.fig']);
    
    % currFilePath = mfilename('fullpath');
    % savePath = [saveFolder filename 'AK' '.mat'];
    % % funclib.save_all(savePath);
    % funclib.save_all(savePath, currFilePath);
    
end %end loop over acquisitions
fc.currentVoltage=[0 0 0];
