
funclib.clear_local_variables()

addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')

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


%% calculate where to sit for flux points
% % fstart=[leftQubitMin rightQubitMin couplerMinJ];
% % fstop=[leftQubitMin rightQubitResonance couplerMinJ];fsteps=25;
% 
% fstart=[leftQubitResonance+0.2 rightQubitMin 0.0];
% fstop=[leftQubitResonance-0.1 rightQubitMin 0.0];fsteps=20;
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
% % ftraj=fc.calculateFluxTrajectory(vtraj);
% % fc.visualizeTrajectories(vtraj,ftraj);
% 
% % fc.currentVoltage=vtraj(:,13);
% 

%% set up acquisitions
clear acquisitionPoints m
tempdx = 0;

%%%%%%%%%%%%%
%%%parameters for overnight 9/1-9/2
%%%%%%%%%%

fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitResonance rightQubitMin 0.0];fsteps=5;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
for ldx = 1:fsteps
    tempdx = tempdx+1;
    mp = {};
    mp.name = ['maxJ_DDDO_LQCsweep_lowerPeak_powerSweep_vtraj' num2str(ldx)]; %left qubit resonant 
    mp.voltagePoint = vtraj(:,ldx);
    mp.startPower = -20; %external attenuation removed from PNAX
    mp.stopPower = 10;
    mp.powerNumPoints = 301;
    mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
    mp.driveFreqs = linspace(5.825e9,5.85e9,20*3.5);
    mp.freqNumPoints = length(mp.driveFreqs);
    mp.waitTime = 10;
    acquisitionPoints(tempdx) = mp;
end

fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitMin rightQubitResonance 0.0];fsteps=5;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 9:13
for ldx = 2:fsteps
    tempdx = tempdx+1;
    mp = {};
    mp.name = ['maxJ_DDDO_RQCsweep_lowerPeak_powerSweep_vtraj' num2str(ldx)]; %right qubit resonant 
    mp.voltagePoint = vtraj(:,ldx); 
%     mp.startPower = -50; %external attenuation removed from PNAX
%     mp.stopPower = -5;
    mp.startPower = -20; %external attenuation removed from PNAX, splitter added
    mp.stopPower = 10;
    mp.powerNumPoints = 301;
    mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
    mp.driveFreqs = linspace(5.825e9,5.85e9,20*3.5);
    mp.freqNumPoints = length(mp.driveFreqs);
    mp.waitTime = 10;
    acquisitionPoints(tempdx) = mp;
end

fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitResonance rightQubitResonance 0.0];fsteps=5;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 9:13
for ldx = 2:fsteps
    tempdx = tempdx+1;
    mp = {};
    mp.name = ['maxJ_DDDO_BQCsweep_lowerPeak_powerSweep_vtraj' num2str(ldx)]; %both qubit resonant 
    mp.voltagePoint = vtraj(:,ldx); 
%     mp.startPower = -50; %external attenuation removed from PNAX
%     mp.stopPower = -5;
    mp.startPower = -20; %external attenuation removed from PNAX, splitter added
    mp.stopPower = 10;
    mp.powerNumPoints = 301;
    mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
    mp.driveFreqs = linspace(5.825e9,5.85e9,20*3.5);
    mp.freqNumPoints = length(mp.driveFreqs);
    mp.waitTime = 10;
    acquisitionPoints(tempdx) = mp;
end

fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitResonance rightQubitMin 0.0];fsteps=5;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
for ldx = 1:fsteps
    tempdx = tempdx+1;
    mp = {};
    mp.name = ['maxJ_DDDO_LQCsweep_upperPeak_powerSweep_vtraj' num2str(ldx)]; %left qubit resonant 
    mp.voltagePoint = vtraj(:,ldx);
    mp.startPower = -20; %external attenuation removed from PNAX
    mp.stopPower = 10;
    mp.powerNumPoints = 301;
    mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
    mp.driveFreqs = linspace(5.88e9,5.92e9,20*3.5);
    mp.freqNumPoints = length(mp.driveFreqs);
    mp.waitTime = 10;
    acquisitionPoints(tempdx) = mp;
end

fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitMin rightQubitResonance 0.0];fsteps=5;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 9:13
for ldx = 2:fsteps
    tempdx = tempdx+1;
    mp = {};
    mp.name = ['maxJ_DDDO_RQCsweep_upperPeak_powerSweep_vtraj' num2str(ldx)]; %right qubit resonant 
    mp.voltagePoint = vtraj(:,ldx); 
%     mp.startPower = -50; %external attenuation removed from PNAX
%     mp.stopPower = -5;
    mp.startPower = -20; %external attenuation removed from PNAX, splitter added
    mp.stopPower = 10;
    mp.powerNumPoints = 301;
    mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
    mp.driveFreqs = linspace(5.88e9,5.92e9,20*3.5);
    mp.freqNumPoints = length(mp.driveFreqs);
    mp.waitTime = 10;
    acquisitionPoints(tempdx) = mp;
end

fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitResonance rightQubitResonance 0.0];fsteps=5;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 9:13
for ldx = 2:fsteps
    tempdx = tempdx+1;
    mp = {};
    mp.name = ['maxJ_DDDO_BQCsweep_upperPeak_powerSweep_vtraj' num2str(ldx)]; %both qubit resonant 
    mp.voltagePoint = vtraj(:,ldx); 
%     mp.startPower = -50; %external attenuation removed from PNAX
%     mp.stopPower = -5;
    mp.startPower = -20; %external attenuation removed from PNAX, splitter added
    mp.stopPower = 10;
    mp.powerNumPoints = 301;
    mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
    mp.driveFreqs = linspace(5.888e9,5.92e9,20*3.5);
    mp.freqNumPoints = length(mp.driveFreqs);
    mp.waitTime = 10;
    acquisitionPoints(tempdx) = mp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% fstart=[(leftQubitResonance+0.2) rightQubitMin 0.0];
% fstop=[(leftQubitResonance-0.1) rightQubitMin 0.0];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = [15,3]
%     tempdx = tempdx+1;
%     mp = {};
% %     mp.name = ['maxJ_DDDO_LQCdispShiftSearch_powerSweep_vtraj' num2str(ldx)]; %left qubit resonant 
%     mp.name = ['maxJ_DDDO_LQCdispShiftSearch_AttnPowerSweep_vtraj' num2str(ldx)]; %left qubit resonant
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -45; %external attenuation removed from PNAX
%     mp.stopPower = 12;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
%     mp.driveFreqs = linspace(5.825e9,5.86e9,50);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end


%%%%%%%%%%%%%%
%%%%big overnight parameter scan.
%%%%%%%%%%%
% fstart=[leftQubitMin rightQubitMin 0.0];
% fstop=[leftQubitResonance rightQubitMin 0.0];fsteps=8;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 1:fsteps
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['maxJ_DDDO_LQCsweep_powerSweep_vtraj' num2str(ldx)]; %left qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -45; %external attenuation removed from PNAX
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
%     mp.driveFreqs = linspace(5.825e9,5.925e9,20*3.5);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end
% 
% fstart=[leftQubitMin rightQubitMin 0.0];
% fstop=[leftQubitMin rightQubitResonance 0.0];fsteps=8;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% % for ldx = 9:13
% for ldx = 2:fsteps
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['maxJ_DDDO_RQCsweep_powerSweep_vtraj' num2str(ldx)]; %right qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx); 
% %     mp.startPower = -50; %external attenuation removed from PNAX
% %     mp.stopPower = -5;
%     mp.startPower = -45; %external attenuation removed from PNAX, splitter added
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
%     mp.driveFreqs = linspace(5.825e9,5.925e9,20*3.5);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end
% 
% fstart=[leftQubitMin rightQubitMin 0.0];
% fstop=[leftQubitResonance rightQubitResonance 0.0];fsteps=8;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% % for ldx = 9:13
% for ldx = 2:fsteps
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['maxJ_DDDO_BQCsweep_powerSweep_vtraj' num2str(ldx)]; %both qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx); 
% %     mp.startPower = -50; %external attenuation removed from PNAX
% %     mp.stopPower = -5;
%     mp.startPower = -45; %external attenuation removed from PNAX, splitter added
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
%     mp.driveFreqs = linspace(5.825e9,5.925e9,20*3.5);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end
% 
% %%%%%%%%%%%%%%minJ
% 
% fstart=[leftQubitMin rightQubitMin couplerMinJ];
% fstop=[leftQubitResonance rightQubitMin couplerMinJ];fsteps=4;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 1:fsteps
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['minJ_DDDO_LQCsweep_powerSweep_vtraj' num2str(ldx)]; %left qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -45; %external attenuation removed from PNAX
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
% %     mp.driveFreqs = linspace(5.8e9,5.95e9,20*8);
%     mp.driveFreqs = linspace(5.825e9,5.905e9,55);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end
% 
% fstart=[leftQubitMin rightQubitMin couplerMinJ];
% fstop=[leftQubitMin rightQubitResonance couplerMinJ];fsteps=4;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 2:fsteps
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['minJ_DDDO_RQCsweep_powerSweep_vtraj' num2str(ldx)]; %right qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -45; %external attenuation removed from PNAX
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
% %     mp.driveFreqs = linspace(5.8e9,5.95e9,20*8);
%     mp.driveFreqs = linspace(5.825e9,5.905e9,55);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end
% 
% fstart=[leftQubitMin rightQubitMin couplerMinJ];
% fstop=[leftQubitResonance rightQubitResonance couplerMinJ];fsteps=4;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 2:fsteps
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['minJ_DDDO_BQCsweep_powerSweep_vtraj' num2str(ldx)]; %both qubits resonant 
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -45; %external attenuation removed from PNAX
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
% %     mp.driveFreqs = linspace(5.8e9,5.95e9,20*8);
%     mp.driveFreqs = linspace(5.825e9,5.905e9,55);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end









% fstart=[leftQubitResonance+0.2 rightQubitMin couplerMinJ];
% fstop=[leftQubitResonance-0.1 rightQubitMin couplerMinJ];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 15
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['minJ_DDDO_LQC_powerSweep_vtraj' num2str(ldx)]; %left qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -45; %external attenuation removed from PNAX
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
% %     mp.driveFreqs = linspace(5.8e9,5.95e9,20*8);
%     mp.driveFreqs = linspace(5.855e9,5.875e9,15) ;
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end

% fstart=[leftQubitResonance+0.2 rightQubitMin 0.0];
% fstop=[leftQubitResonance-0.1 rightQubitMin 0.0];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 15
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['maxJ_DDDO_LQC_powerSweep_vtraj' num2str(ldx)]; %left qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -45; %external attenuation removed from PNAX
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
%     mp.driveFreqs = linspace(5.82e9,6.93e9,70)];
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end

% fstart=[leftQubitMin rightQubitResonance-0.15 0.0];
% fstop=[leftQubitMin rightQubitResonance+0.15 0.0];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% % for ldx = 9:13
% for ldx = 9
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['maxJ_DDDO_RQC_powerSweep_vtraj' num2str(ldx)]; %right qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx); 
% %     mp.startPower = -50; %external attenuation removed from PNAX
% %     mp.stopPower = -5;
%     mp.startPower = -45; %external attenuation removed from PNAX, splitter added
%     mp.stopPower = 5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
% %     mp.driveFreqs = linspace(5.8e9,5.95e9,20*8);
%     mp.driveFreqs = [linspace(5.82e9,5.87e9,35) linspace(5.88e9,5.93e9,35)];
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end

% fstart=[leftQubitResonance+0.2 rightQubitMin 0.0];
% fstop=[leftQubitResonance-0.1 rightQubitMin 0.0];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 15
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['maxJ_SDDO_LQC_powerSweepLeftCav_vtraj' num2str(ldx)]; %left qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -50; %external attenuation removed from PNAX
%     mp.stopPower = -5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
% %     mp.driveFreqs = linspace(5.82e9,5.87e9,35);
%     mp.driveFreqs = linspace(5.88e9,5.93e9,35);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end

% fstart=[leftQubitResonance+0.2 rightQubitMin 0.0];
% fstop=[leftQubitResonance-0.1 rightQubitMin 0.0];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = [9 10 11 13 15]
%     tempdx = tempdx+1;
%     mp = {};
%     mp.name = ['maxJ_SDDO_LQC_powerSweep_vtraj' num2str(ldx)]; %left qubit resonant 
%     mp.voltagePoint = vtraj(:,ldx);
%     mp.startPower = -50; %external attenuation removed from PNAX
%     mp.stopPower = -5;
%     mp.powerNumPoints = 301;
%     mp.drivePowers = linspace(mp.startPower,mp.stopPower,mp.powerNumPoints);
%     mp.driveFreqs = linspace(5.8e9,5.95e9,20*8);
%     mp.freqNumPoints = length(mp.driveFreqs);
%     mp.waitTime = 10;
%     acquisitionPoints(tempdx) = mp;
% end


%% Update and read transmission channel

pnax.params = paramlib.pnax.psweep;

% m = {};
% m.startPower = -20;
% m.stopPower = 10;
% m.powerNumPoints = 301;
% m.drivePowers = linspace(m.startPower,m.stopPower,m.powerNumPoints);
% m.driveFreqs = linspace(5.86e9,5.92e9,20);
% m.freqNumPoints = length(m.driveFreqs);
% m.waitTime = 10;




pnax.DeleteChannel(3);

pnax.SetActiveTrace(1);

% pnax.params.start = 5.75e9;
% pnax.params.stop = 5.97e9;

% pnax.params.points = 2201;

% powerVec = linspace(-20,10,10);

% pnax.params.power = -35;
pnax.PowerOn()
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.AvgClear(1);
% ftrans = pnax.ReadAxis();

%% Transmission power scan

tic; time=fix(clock);
temp = size(acquisitionPoints);
numAcquisitions = temp(2);
for acq = 1:numAcquisitions
    m = acquisitionPoints(acq); %pull the acquisition settings
    
    fc.currentVoltage = m.voltagePoint;
    
    transS21AlongTrajectoryAmpUp = zeros(m.powerNumPoints,m.freqNumPoints);
    transS21AlongTrajectoryPhaseUp = zeros(m.powerNumPoints,m.freqNumPoints);
    transS41AlongTrajectoryAmpUp = zeros(m.powerNumPoints,m.freqNumPoints);
    transS41AlongTrajectoryPhaseUp = zeros(m.powerNumPoints,m.freqNumPoints);

    transS21AlongTrajectoryAmpDown = zeros(m.powerNumPoints,m.freqNumPoints);
    transS21AlongTrajectoryPhaseDown = zeros(m.powerNumPoints,m.freqNumPoints);
    transS41AlongTrajectoryAmpDown = zeros(m.powerNumPoints,m.freqNumPoints);
    transS41AlongTrajectoryPhaseDown = zeros(m.powerNumPoints,m.freqNumPoints);

    for idx=1:m.freqNumPoints
        if idx==1
            tStart=tic;
            time=clock;
            timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
            m.filename=[m.name '_'  timestr];
            
        end
        pnax.params.cwfreq = m.driveFreqs(idx);
        pnax.params.points = m.powerNumPoints;

        % measure S21 and S41 sweeping low to high
        if m.startPower < m.stopPower
            pnax.params.start = m.startPower;
            pnax.params.stop = m.stopPower;
        else
            pnax.params.stop = m.startPower;
            pnax.params.start = m.stopPower;
        end

        pnax.SetActiveTrace(1);
        pnax.AvgClear(1);
        pause(m.waitTime);
        pnax.SetActiveTrace(1);
        [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
        pnax.SetActiveTrace(2);
        pause(0.2);
        [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();

        transS21AlongTrajectoryAmpUp(:,idx)=data_transS21A;
        transS21AlongTrajectoryPhaseUp(:,idx)=data_transS21P;
        transS41AlongTrajectoryAmpUp(:,idx)=data_transS41A;
        transS41AlongTrajectoryPhaseUp(:,idx)=data_transS41P;


        % measure S21 and S41 sweeping high to low
        if m.startPower < m.stopPower
            pnax.params.stop = m.startPower;
            pnax.params.start = m.stopPower;
        else
            pnax.params.start = m.startPower;
            pnax.params.stop = m.stopPower;
        end

        pnax.SetActiveTrace(1);
        pnax.AvgClear(1);
        pause(m.waitTime);
        pnax.SetActiveTrace(1);
        [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
        data_transS21A = fliplr(data_transS21A);
        data_transS21P = fliplr(data_transS21P);

        pnax.SetActiveTrace(2);
        pause(1);
        [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
        data_transS41A = fliplr(data_transS41A);
        data_transS41P = fliplr(data_transS41P);

        transS21AlongTrajectoryAmpDown(:,idx)=data_transS21A;
        transS21AlongTrajectoryPhaseDown(:,idx)=data_transS21P;
        transS41AlongTrajectoryAmpDown(:,idx)=data_transS41A;
        transS41AlongTrajectoryPhaseDown(:,idx)=data_transS41P;

        f = figure(77);
        set(f, 'Position', [68 184 1531 926]);
        clf()
        p = uipanel('Parent',f,'BorderType','none');
        p.Title = m.filename;
        p.TitlePosition = 'centertop';
        p.FontSize = 12;
        p.FontWeight = 'bold';

        % plot low -> high
        subplot(3,2,1,'Parent',p);
        imagesc(m.driveFreqs(1:idx)/1e9,m.drivePowers,transS21AlongTrajectoryAmpUp(:,1:idx)); 
        title('Sweeping Low -> High'); ylabel('Drive Power [dBm]');xlabel('Right Output Frequency [GHz]');
        colorbar(); set(gca,'YDir','normal');


        subplot(3,2,2,'Parent',p);
        imagesc(m.driveFreqs(1:idx)/1e9,m.drivePowers,transS41AlongTrajectoryAmpUp(:,1:idx)); 
        title('Sweeping Low -> High'); ylabel('Drive Power [dBm]');xlabel('Left Output Frequency [GHz]');
        colorbar(); set(gca,'YDir','normal');

        % plot high -> low
        subplot(3,2,3,'Parent',p);
        imagesc(m.driveFreqs(1:idx)/1e9,m.drivePowers,transS21AlongTrajectoryAmpDown(:,1:idx)); 
        title('Sweeping High -> Low'); ylabel('Drive Power [dBm]');xlabel('Right Output Frequency [GHz]');
        colorbar(); set(gca,'YDir','normal');

        subplot(3,2,4,'Parent',p);
        imagesc(m.driveFreqs(1:idx)/1e9,m.drivePowers,transS41AlongTrajectoryAmpDown(:,1:idx)); 
        title('Sweeping High -> Low'); ylabel('Drive Power [dBm]');xlabel('Left Output Frequency [GHz]');
        colorbar(); set(gca,'YDir','normal');

        % plot difference
        subplot(3,2,5,'Parent',p);
        imagesc(m.driveFreqs(1:idx)/1e9,m.drivePowers,transS21AlongTrajectoryAmpUp(:,1:idx)-transS21AlongTrajectoryAmpDown(:,1:idx)); 
        title('Difference (Up-Down)'); ylabel('Drive Power [dBm]');xlabel('Right Output Frequency [GHz]');
        colorbar(); set(gca,'YDir','normal');

        subplot(3,2,6,'Parent',p);
        imagesc(m.driveFreqs(1:idx)/1e9,m.drivePowers,transS41AlongTrajectoryAmpUp(:,1:idx)-transS41AlongTrajectoryAmpDown(:,1:idx));
        title('Difference (Up-Down)'); ylabel('Drive Power [dBm]');xlabel('Left Output Frequency [GHz]');
        colorbar(); set(gca,'YDir','normal');


        if idx==1
            deltaT=toc(tStart);
            estimatedTime=deltaT*m.freqNumPoints*numAcquisitions;
            disp(['Estimated Time is '...
                num2str(estimatedTime/3600),' hrs, or '...
                num2str(estimatedTime/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(estimatedTime),'second'))]);
        end
    end
    pnaxSettings=pnax.params.toStruct();
    
    full_path_info = mfilename('fullpath');
    folder_breaks = regexp(full_path_info,'\');
    current_file_location = full_path_info(1:max(folder_breaks));
    AllFiles = funclib.TextSave(current_file_location);

    saveFolder = ['Z:\Mattias\Data\tunableDimer\PNAXPowerSweepContantFrequency_' runDate '\'];
    isFolder = exist(saveFolder);
    if isFolder == 0
        mkdir(saveFolder)
    end
    save([saveFolder m.filename '.mat'],...
        'CM','f0','fc','pnaxSettings','pnax','m','time',...
        'transS21AlongTrajectoryAmpUp','transS21AlongTrajectoryPhaseUp',...
        'transS41AlongTrajectoryAmpUp','transS41AlongTrajectoryPhaseUp',...
        'transS21AlongTrajectoryAmpDown','transS21AlongTrajectoryPhaseDown',...
        'transS41AlongTrajectoryAmpDown','transS41AlongTrajectoryPhaseDown', 'AllFiles', 'acquisitionPoints')

    savefig([saveFolder m.filename '.fig']);
    
%     currFilePath = mfilename('fullpath');
%     savePath = [saveFolder m.filename 'AK' '.mat'];
%     funclib.save_all(savePath, currFilePath);

    % fc.visualizeTrajectories(vtraj,ftraj);
    % title([filename '_traj'])
    % savefig([saveFolder filename '_traj.fig']);
    toc

end %end loop over all the acquisitions

fc.currentVoltage=[0 0 0];

