addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.01;yoko1.rampinterval=.001;
yoko2.rampstep=.01;yoko2.rampinterval=.001;
yoko3.rampstep=.01;yoko3.rampinterval=.001;

% CM = [.0845 -.00037 -.011; -.0034 0.5597 .0117; .54 -.51 2.3447;]; % update on 09/11
% CM = [1.0 0.00 0.0; 0.00 1.0 0.00; 0 0.0 2.3447*0.9302;]; % update on 09/11




% cal_MAT = [1.0  0.0  0.0; 0.0  0.1704   0.0; 0.1535   -0.1765   2.1810];  %voltage to flux conversion matrix, best guess from 6-21-17

nla = 3.5; %new attenuation of left line
nra = 2.9; %new attenuation of right line
nca = 1.075; %new attenuation of coupler line
cal_MAT = [.0845/nla      -.00037/nra     -.011/nca;     -.0034/nla      0.5597/nra      .0117/nca;      0.1535   -0.1765   2.1810];  %best guess from calibrated bottom row and old matrix, 6-21-17
% cal_MAT = [1.0  0.0  0.0; 0.0  1.0   0.0; 0.1535   -0.1765   2.3447*0.9302];  %voltage to flux conversion matrix
CM = cal_MAT;
% CM = inv(cal_MAT)

% f0 = [.2748; -.1975; 0.2319;]; % after power surge 7/18
% f0 = [.2748; -.1975; 0.064286;]; % after power surge 9/10
% f0 = [.2748; -0.1659; 0.064286;]; % 9/16

% f0 = [.2748; -0.1659; 0.3358 - 0.3333;]; %first try 6-21-17 Doesn't work with best guess matrix

% f0 = [0; 0.4557; 0.3358 - 0.3333;];  %freq min of right qubit is at zero
% f0 = [0; -0.1443; 0.3358 - 0.3333;];  %freq max of right qubit is at zero
f0 = [0.01; -0.1443; 0.3358 - 0.3333;]; %freq max of right qubit is at zero


% f0 = [0; -.1975; -.348;]; % from reboot before power surge
% f0 = [0; -.1975; -.1655;];   from before reboot
fc=fluxController(CM,f0);

fc2 = fluxController2;
EcLeft = 298e6;
EcRight = 298e6;
EjSumLeft = 25.420e9;
EjSumRight = 29.342e9;
fc2.leftQubitFluxToFreqFunc = @(x) sqrt(8.*EcLeft.*EjSumLeft.*abs(cos(pi.*x)))-EcLeft;
fc2.rightQubitFluxToFreqFunc = @(x) sqrt(8.*EcRight.*EjSumRight.*abs(cos(pi.*x)))-EcRight;

%% Update and read transmission channel
pnax.SetActiveTrace(1);
% transWaitTime=7;
% transWaitTime=20;
transWaitTime=20;
pnax.params.start = 5.7e9;
pnax.params.stop = 6.0e9;
% pnax.params.start = 5.80e9;
% pnax.params.stop = 6.00e9;

pnax.params.points = 3201;
% pnax.params.power = -35;

powerVec = linspace(-50,-50,1)

for idx=1:length(powerVec)

pnax.params.power = powerVec(idx);
% pnax.params.power = -35;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
ftrans = pnax.ReadAxis();

clear vtraj ftraj

% %coupler-coupler
% fstart=[0.0 0.0 -1.0];
% fstop=[0.0 0 1.0];fsteps=200;

% %right qubit - coupler
% fstart=[0.0 -3.2 0.0];
% fstop=[0.0 3.6 0.0];fsteps=24;
% fstart=[0.0 -2.0 0.0];
% fstop=[0.0 1.8 0.0];fsteps=26;

% fstart=[0.0 -0.5 0.0];
% fstop=[0.0 0.00 0.0];fsteps=12;
% fstart=[0.0 -0.9 0.0];
% fstop=[0.0 0.4 0.0];fsteps=14;
% fstart=[0.0 -0.6 0.0];
% fstop=[0.0 0.6 0.0];fsteps=14;


% vstart=[0.0 0.0 0.0];
% vstop=[0.0 0.4 0.0];vsteps=26;


%left qubit - coupler
% fstart=[-3.6 0.0 0.0];
% fstop=[3.2 0.0 0.0];fsteps=50;


fstart=[0.0 0.275 0.0];
fstop=[0.0 -0.3159 0.0];fsteps=14;

% fstart=[0.0 -0.7 0.0];
% fstop=[0.0 -0.7 0.0];fsteps=44;


% fstart=[-0.10 0.0 0.0];
% fstop=[0.10 0.0 0.0];fsteps=14;

% fstart=[-0.10 0.0 0.0];
% fstop=[0.0 0.0 0.0];fsteps=12;

% %cheating way to ramp off yokos
% fstart=f0;
% fstop=f0;fsteps=2;


vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);

%% Transmission scan along trajectory
tic; time=fix(clock);
steps=size(vtraj,2); points=pnax.params.points; freqvector=pnax.ReadAxis();
z = zeros(steps,points); transS21AlongTrajectoryAmp=z; transS21AlongTrajectoryPhase=z; transS41AlongTrajectoryAmp=z; transS41AlongTrajectoryPhase=z;
fc.currentVoltage=vtraj(:,1);
for index=1:steps
    if index==1
        tStart=tic;
        time=clock;
%         filename=['couplerFit_LeftInput_couplerCalibration_'  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
%         filename=['couplerFit_LeftInput_rightQubit_couplerCrossCal_'  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
%         filename=['couplerFit_LeftInput_leftQubit_couplerCrossCal_'  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
%         filename=['couplerFit_LeftInput_rightQubitScan_'  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
%         filename=['couplerFit_LeftInput_leftQubitScan_'  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
        filename=['couplerFit_RightInput_rightQubitScan_power' num2str(powerVec(idx)) 'dBm_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
    end
    % update flux/voltage
    fc.currentVoltage=vtraj(:,index);
    % measure S21 and S41
    pnax.SetActiveTrace(1);
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    pnax.SetActiveTrace(1);
    [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
%     pnax.SetActiveTrace(2);
%     [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
    
    transS21AlongTrajectoryAmp(index,:)=data_transS21A;
    transS21AlongTrajectoryPhase(index,:)=data_transS21P;
%     transS41AlongTrajectoryAmp(index,:)=data_transS41A;
%     transS41AlongTrajectoryPhase(index,:)=data_transS4a1P;
    
    figure(158);
%     subplot(1,2,1);
    imagesc(ftrans/1e9,[1,index],transS21AlongTrajectoryAmp(1:index,:)); title(filename); ylabel('step');xlabel('S21 (Cross) Measurement');
%     subplot(1,2,2);
%     imagesc(ftrans/1e9,[1,index],transS41AlongTrajectoryAmp(1:index,:)); title(filename); ylabel('step');xlabel('S41 (Through) Measurement');
    
    if index==1
        deltaT=toc(tStart);
        estimatedTime=steps*deltaT*length(powerVec);
        disp(['Estimated Time is '...
            num2str(estimatedTime/3600),' hrs, or '...
            num2str(estimatedTime/60),' min']);
        disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
            round(estimatedTime),'second'))]);
    end
end
pnaxSettings=pnax.params.toStruct();
saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\PNAX_Calibrations_072317\';
save([saveFolder filename '.mat'],...
    'CM','f0','fc','transWaitTime','pnaxSettings','ftrans','ftraj','vtraj','time','steps',...
    'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase','transS41AlongTrajectoryAmp','transS41AlongTrajectoryPhase')

title(filename)
savefig([saveFolder filename '.fig']);

fc.visualizeTrajectories(vtraj,ftraj);
title([filename '_traj'])
savefig([saveFolder filename '_traj.fig']);
toc
end
fc.currentVoltage=[0 0 0];
