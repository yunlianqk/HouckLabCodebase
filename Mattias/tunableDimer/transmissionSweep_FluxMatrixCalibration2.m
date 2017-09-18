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


tempdx = tempdx+1;
mp = {};
mp.name = ['couplerSweep']; 
fstart=[leftQubitMin rightQubitMin couplerMinJ];
fstop=[leftQubitMin rightQubitMin couplerMaxJ];
fsteps=50;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
mp.vtraj = vtraj;
mp.powerVec = -40 + PNAXattenuation; 
mp.waitTime = 4;
acquisitionPoints(tempdx) = mp;




% tempdx = tempdx+1;
% mp = {};
% mp.name = ['leftQubitSweep']; 
% % fstart=[leftQubitMax 0.0 0.0];
% % fstop=[leftQubitMin 0.0 0.0];fsteps=45;
% % fstart=[leftQubitMax 0.0 0.0];
% % fstop=[0 0.0 0.0];fsteps=10;
% % fstart=[leftQubitMax rightQubitMin 0.0];
% % fstop=[0.25 rightQubitMin 0.0];fsteps=15;
% fstart=[leftQubitMax rightQubitMin 0.0];
% fstop=[0 rightQubitMin 0.0];fsteps=10;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% % mp.vtraj = vtraj(:,10);
% mp.powerVec = -30; 
% % mp.powerVec = -35;
% mp.waitTime = 20;
% % mp.waitTime = 80;
% acquisitionPoints(tempdx) = mp;





% tempdx = tempdx+1;
% mp = {};
% mp.name = ['couplerSweep']; 
% fstart=[leftQubitMin 0 -1.0];
% fstop=[leftQubitMin 0 1.0];fsteps=150;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% mp.powerVec = -20; %external attenuation removed from PNAX
% mp.waitTime = 25;
% acquisitionPoints(tempdx) = mp;
% 
% tempdx = tempdx+1;
% mp = {};
% mp.name = ['rigthQubitSweep']; 
% fstart=[leftQubitMin -1.0 0.0];
% fstop=[leftQubitMin 1.0 0.0];fsteps=45;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% mp.powerVec = -30; %external attenuation removed from PNAX
% mp.waitTime = 35;
% acquisitionPoints(tempdx) = mp;

% tempdx = tempdx+1;
% mp = {};
% mp.name = ['leftQubitSweep']; 
% fstart=[leftQubitMax 0.0 0.0];
% fstop=[leftQubitMin 0.0 0.0];fsteps=45;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% mp.powerVec = -30; %external attenuation removed from PNAX
% mp.waitTime = 35;
% acquisitionPoints(tempdx) = mp;



% tempdx = tempdx+1;
% mp = {};
% mp.name = ['couplerSweep_testing']; 
% fstart=[leftQubitMin 0 -1.0];
% fstop=[leftQubitMin 0 1.0];fsteps=2;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% mp.powerVec = -20; %external attenuation removed from PNAX
% mp.waitTime = 10;
% acquisitionPoints(tempdx) = mp;
% 
% tempdx = tempdx+1;
% mp = {};
% mp.name = ['rigthQubitSweep_testing']; 
% fstart=[leftQubitMin -1.0 0.0];
% fstop=[leftQubitMin 1.0 0.0];fsteps=2;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
%     disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
%     return
% end
% mp.vtraj = vtraj;
% mp.powerVec = -30; %external attenuation removed from PNAX
% mp.waitTime = 10;
% acquisitionPoints(tempdx) = mp;



%%
temp = size(acquisitionPoints);
numAcquisitions = temp(2);
for acq = 1:numAcquisitions
    config = acquisitionPoints(acq);
    
    powerVec = config.powerVec;
    vtraj = config.vtraj;
    ftraj=fc.calculateFluxTrajectory(vtraj);
    
    for pdx = 1:length(powerVec)
        %% Update and read transmission channel
        pnax.SetActiveTrace(1);


        transWaitTime=10;

%         pnax.params.start = 5.55e9;
%         pnax.params.stop = 6.15e9;
        pnax.params.start = 5.75e9;
        pnax.params.stop = 5.95e9;
        

        pnax.params.points = 3201;
        % pnax.params.power = -50;
        % pnax.params.power = -40;
        pnax.params.power = powerVec(pdx); % with external attenuation of 30 dB

        % pnax.params.averages = 65536;
        % pnax.params.averages = 6000;
        pnax.params.averages = 15000;
        pnax.params.ifbandwidth = 10e3;
        pnax.AvgClear(1);
        ftrans = pnax.ReadAxis();

        pnax.params.power = pnax.params.power;
        

        % Transmission scan along trajectory
        tic; time=fix(clock);
        steps=size(vtraj,2); points=pnax.params.points; freqvector=pnax.ReadAxis();
        z = zeros(steps,points); transS21AlongTrajectoryAmp=z; transS21AlongTrajectoryPhase=z; transS41AlongTrajectoryAmp=z; transS41AlongTrajectoryPhase=z;
        fc.currentVoltage=vtraj(:,1);

        for index=1:steps
            if index==1
                tStart=tic;
                time=clock;
                timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
        %         filename=['matrixCalibration_rightInput_' num2str(powerVec(pdx)-PNAXattenuation) 'wAtten_'  timestr];
%                 filename=['matrixCalibration_leftInput_' num2str(powerVec(pdx)-PNAXattenuation) 'wAtten_'  timestr];
                filename=['matrixCalibration_leftInput_' config.name '_'  num2str(powerVec(pdx)-PNAXattenuation) 'wAtten_'  timestr];
%                 filename=['matrixCalibration_rightInput_' config.name '_'  num2str(powerVec(pdx)-PNAXattenuation) 'wAtten_'  timestr];
            end
            % update flux/voltage
            fc.currentVoltage=vtraj(:,index);

            % measure S21 and S41
            pnax.SetActiveTrace(1);
            pnax.AvgClear(1);
            pause(transWaitTime);
            pnax.SetActiveTrace(1);
            [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase(); %right output
            pnax.SetActiveTrace(2);
            pause(1);
            [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase(); %left output

            transS21AlongTrajectoryAmp(index,:)=data_transS21A;
            transS21AlongTrajectoryPhase(index,:)=data_transS21P;
            transS41AlongTrajectoryAmp(index,:)=data_transS41A;
            transS41AlongTrajectoryPhase(index,:)=data_transS41P;

            hFig = figure(158);
            set(hFig, 'Position', [100 100 1000 600]);
            subplot(1,2,1);
            imagesc(ftrans/1e9,[1,index],transS21AlongTrajectoryAmp(1:index,:)); title(filename); ylabel('step');xlabel('Right Output Frequency [GHz]');
            subplot(1,2,2);
            imagesc(ftrans/1e9,[1,index],transS41AlongTrajectoryAmp(1:index,:)); title(''); ylabel('step');xlabel('Left Output Frequency [GHz]');


            if index==1 && pdx == 1 && acq == 1
                temp = size(acquisitionPoints);
                numAcqs = temp (2);
                
                deltaT=toc(tStart);
                estimatedTime=steps*deltaT*length(powerVec)*numAcqs;
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
        saveFolder = ['Z:\Mattias\Data\tunableDimer\PNAX_Calibrations_' runDate '\'];
        if exist(saveFolder)==0
            mkdir(saveFolder);
        end
        save([saveFolder filename '.mat'],...
            'CM','f0','fc','transWaitTime','pnaxSettings','ftrans','ftraj','vtraj','time','steps',...
            'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase','transS41AlongTrajectoryAmp','transS41AlongTrajectoryPhase', 'AllFiles', 'config')

        title(filename)
        savefig([saveFolder filename '.fig']);

        fc.visualizeTrajectories(vtraj,ftraj);
        title([filename '_traj'])
        savefig([saveFolder filename '_traj.fig']);
        toc

        % currFilePath = mfilename('fullpath');
        % savePath = [saveFolder filename 'AK' '.mat'];
        % % funclib.save_all(savePath);
        % funclib.save_all(savePath, currFilePath);

    end %end loop over power vectors
end %end loop over acquisitions
fc.currentVoltage=[0 0 0];
