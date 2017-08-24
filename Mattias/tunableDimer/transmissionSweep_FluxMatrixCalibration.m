addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')

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

% powerVec = linspace(0,-40, 5);
powerVec = [5];

for pdx = 1:length(powerVec)
%% Update and read transmission channel
pnax.SetActiveTrace(1);

% transWaitTime=110;

% transWaitTime=10+13*pdx^2;
% timeVec = 10 + 13.*(1:length(powerVec)).^2;
transWaitTime=17;
    
pnax.params.start = 5.55e9;
pnax.params.stop = 6.15e9;

pnax.params.points = 3201;
% pnax.params.power = -50;
% pnax.params.power = -40;
pnax.params.power = powerVec(pdx); % with external attenuation of 30 dB

pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
ftrans = pnax.ReadAxis();

clear vtraj ftraj

% vstart=[0.0 0.0 0.0225];
% vstop=[0.0 2.0 0.0225];fsteps=40;

% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% ftraj=fc.calculateFluxTrajectory(vtraj);
% fc.visualizeTrajectories(vtraj,ftraj);

% fstart=[-3.5 0.0 0.0];
% fstop=[3.5 0.0 0.0];fsteps=30;

fstart=[leftQubitMin (rightQubitResonance-0.15) couplerMinJ];
fstop=[leftQubitMin (rightQubitResonance+0.15) couplerMinJ];fsteps=50;

% fstart=[leftQubitResonace (rightQubitResonace-0.15) 0];
% fstop=[leftQubitResonace (rightQubitResonace+0.15) 0];fsteps=6;



vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);

voltageCutoff = 3.5;

if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end

vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);

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
        filename=['matrixCalibration_rightInput_' num2str(powerVec(pdx)-30) 'wAtten_'  timestr];
        
    end
    % update flux/voltage
    fc.currentVoltage=vtraj(:,index);
    
    % measure S21 and S41
    pnax.SetActiveTrace(1);
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    pnax.SetActiveTrace(1);
    [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
    pnax.SetActiveTrace(2);
    pause(1);
    [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
    
    transS21AlongTrajectoryAmp(index,:)=data_transS21A;
    transS21AlongTrajectoryPhase(index,:)=data_transS21P;
    transS41AlongTrajectoryAmp(index,:)=data_transS41A;
    transS41AlongTrajectoryPhase(index,:)=data_transS41P;
    
    hFig = figure(158);
    set(hFig, 'Position', [100 100 1000 600]);
    subplot(1,2,1);
    imagesc(ftrans/1e9,[1,index],transS21AlongTrajectoryAmp(1:index,:)); title(filename); ylabel('step');xlabel('Right Output Frequency [GHz]');
    subplot(1,2,2);
    imagesc(ftrans/1e9,[1,index],transS41AlongTrajectoryAmp(1:index,:)); title(filename); ylabel('step');xlabel('Left Output Frequency [GHz]');
    

    if index==1 && pdx == 1
        deltaT=toc(tStart);
        estimatedTime=steps*deltaT*sum(timeVec)/timeVec(1);
        disp(['Estimated Time is '...
            num2str(estimatedTime/3600),' hrs, or '...
            num2str(estimatedTime/60),' min']);
        disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
            round(estimatedTime),'second'))]);
    end
end
pnaxSettings=pnax.params.toStruct();
saveFolder = 'C:\Users\BFG\Documents\Mattias\tunableDimer\PNAX_Calibrations_082218\';
if exist(saveFolder)==0
    mkdir(saveFolder);
end
save([saveFolder filename '.mat'],...
    'CM','f0','fc','transWaitTime','pnaxSettings','ftrans','ftraj','vtraj','time','steps',...
    'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase','transS41AlongTrajectoryAmp','transS41AlongTrajectoryPhase')

title(filename)
savefig([saveFolder filename '.fig']);

fc.visualizeTrajectories(vtraj,ftraj);
title([filename '_traj'])
savefig([saveFolder filename '_traj.fig']);
toc

currFilePath = mfilename('fullpath');
savePath = [saveFolder filename 'AK' '.mat'];
% funclib.save_all(savePath);
funclib.save_all(savePath, currFilePath);

end
fc.currentVoltage=[0 0 0];
