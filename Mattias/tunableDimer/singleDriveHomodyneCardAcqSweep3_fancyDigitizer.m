
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
% CM = [1 0 0; 0 1 0; 120/(7*39) -120/(7*40) 1/0.45];  % Updated 8/12 to include qubit effects on coupler
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


%%

% use the vtraj from matrixCalibration_rightInput_-25wAtten_20170823_1137
% fstart=[leftQubitMin (rightQubitResonance-0.15) couplerMinJ];
% fstop=[leftQubitMin (rightQubitResonance+0.15) couplerMinJ];fsteps=50;
% fstart=[leftQubitMin (rightQubitResonance-0.15) 0.22];
% fstop=[leftQubitMin (rightQubitResonance+0.15) 0.22];fsteps=40;
fstart=[leftQubitMin (rightQubitResonance-0.15) 0];
fstop=[leftQubitMin (rightQubitResonance+0.15) 0];fsteps=20;

% fstart=[(leftQubitResonance) rightQubitMin-0.15 couplerMinJ];
% fstop=[(leftQubitResonance) rightQubitMin+0.15 couplerMinJ];fsteps=50;

% fstart=[leftQubitResonance rightQubitMin 0.0];
% fstop=[leftQubitResonance rightQubitResonance 0.0];fsteps=5;

% fstart=[(leftQubitResonance-0.15) rightQubitMin 0.22];
% fstop=[(leftQubitResonance+0.2) rightQubitMin 0.22];fsteps=25;

% fstart=[(leftQubitResonance-0.1) rightQubitMin 0.0];
% fstop=[(leftQubitResonance+0.2) rightQubitMin 0.0];fsteps=20; %step 6

% fstart=[(leftQubitResonance-0.15) rightQubitMin 0.22];
% fstop=[(leftQubitResonance+0.2) rightQubitMin 0.22];fsteps=25; %step 10

% fstart=[(leftQubitResonance+0.2) rightQubitMin 0.0];
% fstop=[(leftQubitResonance-0.1) rightQubitMin 0.0];fsteps=20;


vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
voltageCutoff = 3.5;

if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);

vtraj(:,9)
% fc.currentVoltage = vtraj(:,23); 
% fc.currentVoltage = vtraj(:,19); 

%%   set up all the different measurements
% targetTimeDuration = 50e-6;
targetTimeDuration = 100e-6;
samplerate = 1.6e9/32;

plotMode = 'multi';
% plotMode = 'single';

clear acquisitionPoints measurementPoint
tempdx = 0;

fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitResonance rightQubitResonance 0.0];fsteps=8;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
for ldx = 1:fsteps
% for ldx = 1
    tempdx = tempdx+1;
    measurementPoint = {};
    measurementPoint.name = ['maxJ_DDDO_BQCsweep_maxHysteresis_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
    measurementPoint.voltagePoint = vtraj(:,ldx);
%     measurementPoint.powerSetPoints = [1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6];
    measurementPoint.powerSetPoints = [linspace(-5,-1,10)];
    measurementPoint.numReads = 10;
    measurementPoint.segments = 5;
%     measurementPoint.numReads = 5;
%     measurementPoint.segments = 100;
    measurementPoint.probeFrequency = (5.895e9);
    measurementPoint.averages = 6000/measurementPoint.segments;
    acquisitionPoints(tempdx) = measurementPoint;
end


% fstart=[leftQubitMin rightQubitMin couplerMinJ];
% fstop=[leftQubitResonance rightQubitMin couplerMinJ];fsteps=8;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 1:fsteps
% for ldx = 1
%     tempdx = tempdx+1;
%     measurementPoint = {};
%     measurementPoint.name = ['minJ_DDDO_LQC_maxHysteresis_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.voltagePoint = vtraj(:,ldx);
%     measurementPoint.powerSetPoints = [1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6];
%     measurementPoint.powerSetPoints = [linspace(1.4, 2.6,10)];
%     measurementPoint.numReads = 10;
%     measurementPoint.segments = 5;
%     measurementPoint.numReads = 5;
%     measurementPoint.segments = 100;
%     measurementPoint.probeFrequency = (5.89e9);
%     measurementPoint.averages = 6000/measurementPoint.segments;
%     acquisitionPoints(tempdx) = measurementPoint;
% end


% 09/01/17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





% fstart=[leftQubitMin rightQubitMin couplerMinJ];
% fstop=[leftQubitMin rightQubitResonance couplerMinJ];fsteps=8;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 1:fsteps
% % for ldx = 1:fsteps
%     tempdx = tempdx+1;
%     measurementPoint = {};
%     measurementPoint.name = ['minJ_DDDO_RQC_maxHysteresis_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.voltagePoint = vtraj(:,ldx);
%     measurementPoint.powerSetPoints = [1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1];
%     measurementPoint.numReads = 20;
%     measurementPoint.segments = 50;
% %     measurementPoint.numReads = 5;
% %     measurementPoint.segments = 100;
%     measurementPoint.probeFrequency = (5.89e9);
%     measurementPoint.averages = 6000/measurementPoint.segments;
%     acquisitionPoints(tempdx) = measurementPoint;
% end





% fstart=[leftQubitResonance+0.2 rightQubitMin 0.0];
% fstop=[leftQubitResonance-0.1 rightQubitMin 0.0];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 15
%     tempdx = tempdx+1;
%     measurementPoint = {};
%     measurementPoint.name = ['maxJ_DDDO_LQC_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.voltagePoint = vtraj(:,ldx);
% %     measurementPoint.powerSetPoints =linspace(-20,-10,11);
% %     measurementPoint.powerSetPoints =linspace(-9,0,10);
%     measurementPoint.powerSetPoints =-0.85;
%     measurementPoint.numReads = 5;
%     measurementPoint.segments = 100;
% %     measurementPoint.numReads = 5;
% %     measurementPoint.segments = 100;
%     measurementPoint.probeFrequency = (5.892e9);
%     measurementPoint.averages = 6000/measurementPoint.segments;
%     acquisitionPoints(tempdx) = measurementPoint;
% end

% fstart=[leftQubitMin rightQubitResonance-0.15 0.0];
% fstop=[leftQubitMin rightQubitResonance+0.15 0.0];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 9
%     tempdx = tempdx+1;
%     measurementPoint = {};
%     measurementPoint.name = ['maxJ_DDDO_RQC_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.voltagePoint = vtraj(:,ldx);
% %     measurementPoint.powerSetPoints =linspace(-20,-10,11);
% %     measurementPoint.powerSetPoints =linspace(-9,0,10);
%     measurementPoint.powerSetPoints =-5;
%     measurementPoint.numReads = 5;
%     measurementPoint.segments = 100;
% %     measurementPoint.numReads = 5;
% %     measurementPoint.segments = 100;
%     measurementPoint.probeFrequency = (5.9e9);
%     measurementPoint.averages = 6000/measurementPoint.segments;
%     acquisitionPoints(tempdx) = measurementPoint;
% end

% fstart=[leftQubitResonance+0.2 rightQubitMin couplerMinJ];
% fstop=[leftQubitResonance-0.1 rightQubitMin couplerMinJ];fsteps=20;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% for ldx = 15
%     tempdx = tempdx+1;
%     measurementPoint = {};
%     measurementPoint.name = ['minJ_DDDO_LQC_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.voltagePoint = vtraj(:,ldx);
% %     measurementPoint.powerSetPoints =linspace(-5,4,10);
%     measurementPoint.powerSetPoints =1.9;
% %     measurementPoint.powerSetPoints =-20;
%     measurementPoint.numReads = 20;
%     measurementPoint.segments = 10;
%     measurementPoint.probeFrequency = 5.89e9;
%     measurementPoint.averages = 6000/measurementPoint.segments;
%     acquisitionPoints(tempdx) = measurementPoint;
% end


% tempdx = 0;
% % for ldx = 9:13
% for ldx = 14
%     tempdx = tempdx+1;
%     measurementPoint = {};
% %     measurementPoint.name = ['maxJ_DDDO_LQC_leftMode_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.name = ['maxJ_SDDO_LQC_leftMode_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.voltagePoint = vtraj(:,ldx);
% %     measurementPoint.powerSetPoints =linspace(-40,-20,10);
% %     measurementPoint.powerSetPoints =[-23, -22];
%     measurementPoint.powerSetPoints =[-21, -20, -19, -18, -17, -16];
% %     measurementPoint.powerSetPoints =linspace(-37,-27,11);
%     measurementPoint.powerSetPoints =[-27,-26, -25, -24];
% %     measurementPoint.powerSetPoints =[-17];
%     measurementPoint.numReads = 5;
%     measurementPoint.segments = 10;
%     measurementPoint.probeFrequency = 5.8425e9;
%     measurementPoint.averages = 6000/measurementPoint.segments;
%     acquisitionPoints(tempdx) = measurementPoint;
% end

% tempdx = 0;
% % for ldx = 9:13
% for ldx = 9
%     tempdx = tempdx+1;
%     measurementPoint = {};
% %     measurementPoint.name = ['maxJ_DDDO_LQC_rightmode_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.name = ['maxJ_SDDO_LQC_rightmode_vtraj' num2str(ldx)]; %left qubit in resonance with left cavity
%     measurementPoint.voltagePoint = vtraj(:,ldx);
%     measurementPoint.powerSetPoints =linspace(-40,-20,10);
% %     measurementPoint.powerSetPoints =[-23, -22];
% %     measurementPoint.powerSetPoints =[-21, -19, -17, -15, -13, -11];
%     measurementPoint.powerSetPoints =[-7];
%     measurementPoint.numReads = 5;
%     measurementPoint.segments = 10;
%     measurementPoint.probeFrequency = 5.909e9;
%     measurementPoint.averages = 6000/measurementPoint.segments;
%     acquisitionPoints(tempdx) = measurementPoint;
% end

% measurementPoint = {};
% measurementPoint.name = 'maxJ_DDDO_RQC_rightMode'; %right qubit in resonance with right cavity
% measurementPoint.voltagePoint = [1.4290 -0.2435 -0.2671];
% % measurementPoint.powerSetPoints =[-26.5, -25.5, -24,5, -23.5];
% measurementPoint.powerSetPoints =[-21, -19, -17, -15, -13, -11];
% measurementPoint.powerSetPoints =[-11];
% measurementPoint.numReads = 5;
% measurementPoint.segments = 10;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;


% measurementPoint = {};
% % measurementPoint.name = 'maxJ_DDDO_RQC_leftMode'; %right qubit in resonance with right cavity
% measurementPoint.name = 'maxJ_SDDO_RQC_leftMode'; %right qubit in resonance with right cavity
% measurementPoint.voltagePoint = [1.4290 -0.2435 -0.2671];
% % measurementPoint.powerSetPoints =linspace(-40,-20,20);
% % measurementPoint.powerSetPoints =linspace(-24,-17,5);
% % measurementPoint.powerSetPoints =linspace(-25,-20.5,5);
% % measurementPoint.powerSetPoints =[-24];
% % measurementPoint.powerSetPoints =[-26.5, -25.5, -24,5, -23.5];
% % measurementPoint.powerSetPoints =[-23.5, -20.5, -17, -15];
% % measurementPoint.powerSetPoints =[ -21, -19, -17, -15, -13];
% measurementPoint.powerSetPoints =[ -25];
% measurementPoint.numReads = 5;
% measurementPoint.segments = 10;
% measurementPoint.probeFrequency = 5.8425e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;











% for ldx = 1:fsteps
% % for ldx = 5
% measurementPoint = {};
% measurementPoint.name = ['maxJ_dualDrive_vtraj' num2str(ldx)];
% measurementPoint.voltagePoint = vtraj(:,ldx);
% measurementPoint.powerSetPoints =linspace(-18,-9,11);
% % temp = linspace(-18,-9,11);
% % measurementPoint.powerSetPoints = temp(2:end);
% measurementPoint.numReads = 500;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(ldx) = measurementPoint;
% end

% measurementPoint = {};
% measurementPoint.name = 'maxJ_dualDrive_leftMode_dualOutput';
% measurementPoint.voltagePoint = [-1.5198 -0.5908 -0.2207];
% % % measurementPoint.powerSetPoints =linspace(-40,-20,20);
% measurementPoint.powerSetPoints =linspace(-40,-20,10);
% % measurementPoint.powerSetPoints =[-30];
% measurementPoint.numReads = 5;
% measurementPoint.segments = 10;
% % measurementPoint.probeFrequency = 5.844e9;
% measurementPoint.probeFrequency = 5.841e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;

% measurementPoint = {};
% measurementPoint.name = 'mediumJ_dualDrive_leftMode_dualOutput';
% measurementPoint.voltagePoint = [-1.4873 -0.5910 0.3136];
% % measurementPoint.powerSetPoints =linspace(-40,-20,20);
% % measurementPoint.powerSetPoints =linspace(-23,-19.5,8);
% measurementPoint.powerSetPoints = [-20.5];
% measurementPoint.numReads = 5;
% measurementPoint.segments = 10;
% measurementPoint.probeFrequency = 5.841e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;




% measurementPoint = {};
% measurementPoint.name = 'maxJ_singleDrive_dualOutput';
% measurementPoint.voltagePoint = [1.4290 -0.2435 -0.2671];
% % measurementPoint.powerSetPoints =linspace(-40,-20,20);
% % measurementPoint.powerSetPoints =linspace(-24,-17,5);
% % measurementPoint.powerSetPoints =linspace(-25,-20.5,5);
% % measurementPoint.powerSetPoints =[-24];
% % measurementPoint.powerSetPoints =[-26.5, -25.5, -24,5, -23.5];
% measurementPoint.powerSetPoints =[-23.5, -20.5, -17, -15];
% measurementPoint.numReads = 5;
% measurementPoint.segments = 10;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;



% measurementPoint = {};
% % measurementPoint.name = 'maxJ_singleDrive_rightInputLeftOutput';
% measurementPoint.name = 'maxJ_singleDrive_rightInputLeftOutput';
% measurementPoint.voltagePoint = [1.4290 -0.2435 -0.2671];
% % measurementPoint.powerSetPoints =linspace(-40,-20,20);
% % measurementPoint.powerSetPoints =linspace(-24,-17,5);
% % measurementPoint.powerSetPoints =linspace(-25,-20.5,5);
% measurementPoint.powerSetPoints =[-24];
% measurementPoint.numReads = 5;
% measurementPoint.segments = 10;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;


% measurementPoint = {};
% measurementPoint.name = 'maxJ_dualDriveSplit_LeftDetunedRightClose';
% measurementPoint.voltagePoint = [1.4247 -0.2773 -0.2728];
% measurementPoint.powerSetPoints =linspace(-36,-25,10);
% measurementPoint.numReads = 5;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.912e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;

% measurementPoint = {};
% measurementPoint.name = 'maxJ_dualDriveSplit_LeftDetunedRightClose';
% measurementPoint.voltagePoint = [1.4247 -0.2773 -0.2728];
% measurementPoint.powerSetPoints =linspace(-15,-5,10);
% measurementPoint.numReads = 5;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.93e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;





% measurementPoint = {};
% measurementPoint.name = 'maxJ_dualDriveSplit_LeftDetunedRightClose';
% measurementPoint.voltagePoint = [1.4195 -0.3186 -0.2798];
% measurementPoint.powerSetPoints =linspace(-34,-26,10);
% measurementPoint.numReads = 5;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.912e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% measurementPoint = {};
% measurementPoint.name = 'maxJ_dualDriveSplit_leftResonance';
% measurementPoint.voltagePoint = [-1.2403 -0.6374 0.1603];
% measurementPoint.powerSetPoints =linspace(-18.0, -15.0, 20);
% measurementPoint.numReads = 500;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;
% 
% measurementPoint = {};
% measurementPoint.name = 'minJ_dualDriveSplit_leftResonance';
% measurementPoint.voltagePoint = [-1.2364 -0.5894 0.3657];
% measurementPoint.powerSetPoints = linspace(-27, -10,20);
% measurementPoint.numReads = 500;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.872e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(2) = measurementPoint;


% %%%max J % right qubit and left qubit in resonance
% measurementPoint = {};
% measurementPoint.name = 'maxJ_dualDriveSplit_rightResonance';
% % measurementPoint.voltagePoint = [-1.2465 -0.6374 0.1603];
% measurementPoint.voltagePoint = [1.4290, -0.2435, -0.2671];
% % measurementPoint.powerSetPoints = linspace(-45,-30,15);
% % measurementPoint.powerSetPoints =linspace(-34.5, -29.5,5);
% measurementPoint.powerSetPoints =linspace(-19.0, -15,20);
% measurementPoint.numReads = 500;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(4) = measurementPoint;

% %%%small J
% measurementPoint = {};
% measurementPoint.name = 'minJ_dualDriveSplit_doubleResonance';
% measurementPoint.voltagePoint = [-1.2404, -0.6210, 0.3603];
% % measurementPoint.powerSetPoints = linspace(-29,-25,5);
% % measurementPoint.powerSetPoints = linspace(-29,-24,10);
% % measurementPoint.powerSetPoints = -27*ones(1,16);
% measurementPoint.powerSetPoints = linspace(-25, -15,20);
% measurementPoint.numReads = 500;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.872e9;
% measurementPoint.averages = 6000/measurementPoint.segments; %number of averages for background measurement
% acquisitionPoints(5) = measurementPoint;
% 
% %%%small J
% measurementPoint = {};
% measurementPoint.name = 'minJ_dualDriveSplit_rightResonance';
% measurementPoint.voltagePoint = [1.4351, -0.2272, -0.0671];
% % measurementPoint.powerSetPoints = linspace(-29,-25,5);
% % measurementPoint.powerSetPoints = linspace(-29,-24,10);
% % measurementPoint.powerSetPoints = -27*ones(1,16);
% measurementPoint.powerSetPoints = linspace(-25, -15,20);
% measurementPoint.numReads = 500;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.872e9;
% measurementPoint.averages = 6000/measurementPoint.segments; %number of averages for background measurement
% acquisitionPoints(6) = measurementPoint;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Set up Trigger

% triggen.period = 10e-6;
triggen.offset=1;
triggen.vpp=2;
triggen.PowerOn();


%% Set up Generators

rfgen.ModOff();
logen.ModOff();

rfgen.PowerOn();

% logen.power = 12.5;
logen.power = 15.5; %split LO
logen.PowerOn();

corrparams.Int_Freq = 0e6;

rfgen.freq = 5.908e9;
logen.freq = rfgen.freq + corrparams.Int_Freq;

%% Set Up Card Parameters

% cardparams_fromDefault=paramlib.m9703a();   %default parameters
% card.SetParams_MS(cardparams_fromDefault); %magic function that seems to reset some errors even though it doesn't set card parameters well
% 
% % % % % % %store away and act on derrived settings
% % % % % % cardparams =cardparams_fromDefault;
% % % % % % sampleinterval = 1/cardparams_fromDefault.samplerate;
% % % % % % cardparams.sampleinterval = sampleinterval;
% % % % % % targetTimeDuration = cardparams_fromDefault.samples/cardparams_fromDefault.samplerate;
% % % % % % triggen.period = cardparams_fromDefault.trigPeriod;
% % % % % % cardparams.trigPeriod = triggen.period;

% cardparams = paramlib.acqiris();
cardparams = paramlib.m9703a();
% cardparams.fullscale = 0.5;
cardparams.fullscale = 1;
cardparams.offset = 0e-6;

% cardparams.trigSource = 'External1';
cardparams.trigSource = 'Channel1';

cardparams.samplerate = samplerate;
exponent = nextpow2(targetTimeDuration*cardparams.samplerate);
actualTimeDuration = (2^exponent)/cardparams.samplerate;
cardparams.samples = 2^exponent;
if cardparams.samples<2048
    disp('CARD NEEDS MORE SAMPLES, we think.')
    return
end
cardparams.averages = 4;
cardparams.segments = 5;
cardparams.delaytime = 1e-6;
cardparams.couplemode = 'DC';
corrparams.limCount=1;

triggen.period = actualTimeDuration+1e-6;
% cardparams.trigPeriod = triggen.period;

card.SetParams(cardparams);
% cardparams.trigPeriod = triggen.period; %this guy isn't handled right by the code right now. Putting it back.

% Time axis in us
timeaxis = (0:card.params.samples-1)/card.params.samplerate/1e-6;

%% loop over the different types of acqusitions

clear IData QData

temp = size(acquisitionPoints);
numAcquisitions = temp(2);

exponent = nextpow2(targetTimeDuration*cardparams.samplerate);
actualTimeDuration = (2^exponent)/cardparams.samplerate;
cardparams.samples = 2^exponent;
triggen.period = actualTimeDuration+1e-6;
% cardparams.trigPeriod = triggen.period;
card.SetParams(cardparams);
% cardparams.trigPeriod = triggen.period; %this guy isn't handled right by the code right now. Putting it back.

% avgingWindows = [2.5, 5, 10, 20, 50, 100]*1e-6;
avgingWindows = [2, 5, 10, 20]*1e-6; %%%%%!!!!!!!!!!!!!! must be integer divisions of target time duration, maybe not any more ?
% avgingWindows = [0.5, 1, 2, 5]*1e-6;
numDivisions = floor(targetTimeDuration./avgingWindows);

acquisitionChannels = [3,4,5,6];

% for acq = 5
for acq = 1:numAcquisitions
    config = acquisitionPoints(acq);
    %     numReads = config.numReads; %number of card acquisitions
    numCardReads = config.numReads;
    cardparams.segments = config.segments; %will be set right before taking background or measureing data
    
    drive.powerSetPoints = config.powerSetPoints;
    
    fc.currentVoltage = config.voltagePoint;
    
    %set the frequency of the rf gan for this measurement
    rfgen.freq = config.probeFrequency;
    logen.freq = rfgen.freq;
    
    avgOutput1 = zeros(1,length(drive.powerSetPoints));
    avgOutput2 = zeros(1,length(drive.powerSetPoints));
    for pdx = 1:length(drive.powerSetPoints)
        ampDataAvgMat = zeros(numCardReads*cardparams.segments,numDivisions(1)); %rezero data matrix
        ampDataAvgMat2 = zeros(numCardReads*cardparams.segments,numDivisions(1)); %rezero data matrix
        
        tStart=tic;
        time=clock;
        timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
        filename=['dualDriveHomodyne_' config.name '_' num2str(drive.powerSetPoints(pdx)) 'dBm_'  timestr];
        
        if pdx > 1 && drive.powerSetPoints(pdx) == drive.powerSetPoints(pdx-1)
            1;
        else
            rfgen.power = drive.powerSetPoints(pdx);
        end
        
        rfgen.power = drive.powerSetPoints(pdx);
        
%         ampDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
%         IDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
%         QDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
%         IDataAvg = zeros(1,numCardReads*cardparams.segments);
%         QDataAvg = zeros(1,numCardReads*cardparams.segments);
%         ampDataAvg = zeros(1,numCardReads*cardparams.segments);
%         ampDataPostAvg = zeros(1,numCardReads*cardparams.segments);
%         
        
        for idx = 1:numCardReads %loop over the reads
            tTrialStart  = tic;
            if pdx ==1 && idx ==1
                tStart=tic;
                time=clock;
            end
            
            % find a background measurement
            rfgen.PowerOff();
            pause(0.1);
%             cardparams.segments = config.averages; %fancy card doesn't do on board averages
            cardparams.segments = 600;
            cardparams.averages = 1;
            card.SetParams(cardparams);
%             cardparams.trigPeriod = triggen.period; %this guy isn't handled right by the code right now. Putting it back.
            
            pause(0.1);
            
            
            data = card.ReadChannels64_multiSegment(acquisitionChannels);
            dataSize = size(data);
            IDataBackground = data(1,:,:);
            IDataBackground = reshape(IDataBackground, dataSize(2), dataSize(3));
            QDataBackground = data(2,:,:);
            QDataBackground = reshape(QDataBackground, dataSize(2), dataSize(3));
            I2DataBackground = data(3,:,:);
            I2DataBackground = reshape(I2DataBackground, dataSize(2), dataSize(3));
            Q2DataBackground = data(4,:,:);
            Q2DataBackground = reshape(Q2DataBackground, dataSize(2), dataSize(3));
%             [IDataBackground, QDataBackground] = card.ReadIandQ();
%             IDataBackground = IDataBackground(:,1:int32(cardparams.samples));
%             QDataBackground = QDataBackground(:,1:int32(cardparams.samples));

            %get the average background
            IDataBackground = mean(IDataBackground(:));
            QDataBackground = mean(QDataBackground(:));
            I2DataBackground = mean(I2DataBackground(:));
            Q2DataBackground = mean(Q2DataBackground(:));

            
            %setup real acquisition
            rfgen.PowerOn();
            cardparams.averages = 1;
            cardparams.segments = config.segments; %back to a normal number of segments
            card.SetParams(cardparams);
%             cardparams.trigPeriod = triggen.period; %this guy isn't handled right by the code right now. Putting it back.
            

            % acquire new data set
%             [IDataTemp, QDataTemp] = card.ReadIandQ();
%             IDataTemp = IDataTemp(:,1:int32(cardparams.samples))-IDataBackground;
%             QDataTemp = QDataTemp(:,1:int32(cardparams.samples))-QDataBackground;
            data = card.ReadChannels64_multiSegment(acquisitionChannels);
            dataSize = size(data);
            IDataTemp = data(1,:,:);
            IDataTemp = reshape(IDataTemp, dataSize(2), dataSize(3));
            QDataTemp = data(2,:,:);
            QDataTemp = reshape(QDataTemp, dataSize(2), dataSize(3));
            I2DataTemp = data(3,:,:);
            I2DataTemp = reshape(I2DataTemp, dataSize(2), dataSize(3));
            Q2DataTemp = data(4,:,:);
            Q2DataTemp = reshape(Q2DataTemp, dataSize(2), dataSize(3));
            
            IDataTemp = IDataTemp(:,1:int32(cardparams.samples))-IDataBackground;
            QDataTemp = QDataTemp(:,1:int32(cardparams.samples))-QDataBackground;
            I2DataTemp = I2DataTemp(:,1:int32(cardparams.samples))-I2DataBackground;
            Q2DataTemp = Q2DataTemp(:,1:int32(cardparams.samples))-Q2DataBackground;
            
            
            
            minSamplesPerDivision = (targetTimeDuration*cardparams.samplerate)/numDivisions(1);
            
            % down-sample averaging
            for divdx = 1:numDivisions(1)
                ISection = IDataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                QSection = QDataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                
                Imean = mean(ISection,2);
                Qmean = mean(QSection,2);
                ampMean = Imean.^2 + Qmean.^2;
                
                ampDataAvgMat((idx-1)*cardparams.segments+1:(idx)*cardparams.segments,divdx) = ampMean;
                
                
                %second output
                I2Section = I2DataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                Q2Section = Q2DataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                
                I2mean = mean(I2Section,2);
                Q2mean = mean(Q2Section,2);
                ampMean2 = I2mean.^2 + Q2mean.^2;
                
                ampDataAvgMat2((idx-1)*cardparams.segments+1:(idx)*cardparams.segments,divdx) = ampMean2;
            end
            
            deltaT_trialEnd = toc(tTrialStart);
            if idx==1 && pdx == 1 && acq == 1
                disp(['single trial time = ' num2str(deltaT_trialEnd)])
                deltaT=toc(tStart);
                %                 estimatedTime=deltaT*length(drive.powerVec)*length(drive.powerSetPoints)*mean(cardAcqLengths)/cardAcqLengths(1);
                temp = size(acquisitionPoints);
                numAcqs = temp (2);
                estimatedTime=deltaT*numCardReads*length(drive.powerSetPoints)*numAcqs;
                disp(['Estimated Time is '...
                    num2str(estimatedTime/3600),' hrs, or '...
                    num2str(estimatedTime/60),' min']);
                disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                    round(estimatedTime),'second'))]);
            end
            
            numBins=80;
            %plot the data as it comes in
            g = figure(22+acq);
            clf()
            set(g, 'Position',  [41 103 1782 1002]);
            p = uipanel('Parent',g,'BorderType','none');
            p.Title = filename;
            p.TitlePosition = 'centertop';
            p.FontSize = 12;
            p.FontWeight = 'bold';

            subplot(1,4,1,'Parent',p);
            yaxis =1:idx*cardparams.segments;
            xaxis =1:numDivisions(1) *avgingWindows(1)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgMat(1:idx*cardparams.segments,:));
            title(['ampDataAvgMat']);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(2,4,2,'Parent',p);
            hist(reshape(ampDataAvgMat(1:idx*cardparams.segments,:),1,idx*cardparams.segments*numDivisions(1)),numBins)
            title('histogram of everything at min binning ')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
            subplot(2,4,6,'Parent',p);
            tempSection = ampDataAvgMat((1+(idx-1)*cardparams.segments):idx*cardparams.segments,:);
            hist(reshape(tempSection,1,cardparams.segments*numDivisions(1)),numBins)
            title('histogram of latest read at min binning')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
            
            %second channel
            subplot(1,4,3,'Parent',p);
            yaxis =1:idx*cardparams.segments;
            xaxis =1:numDivisions(1) *avgingWindows(1)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgMat2(1:idx*cardparams.segments,:));
            title(['ampDataAvgMat2']);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(2,4,4,'Parent',p);
            hist(reshape(ampDataAvgMat2(1:idx*cardparams.segments,:),1,idx*cardparams.segments*numDivisions(1)),numBins)
            title('histogram of everything at min binning2 ')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
            subplot(2,4,8,'Parent',p);
            tempSection = ampDataAvgMat2((1+(idx-1)*cardparams.segments):idx*cardparams.segments,:);
            hist(reshape(tempSection,1,cardparams.segments*numDivisions(1)),numBins)
            title('histogram of latest read at min binning2')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
        end %end loop over card reads
        
        
        
        
        %do all further down sampling and store result.
        ampDataAvgStruct = {};
        ampDataAvgStruct2 = {};

        ampDataAvgStruct.(['avgWind' num2str(avgingWindows(1)*10^9) 'ns']) = ampDataAvgMat;
        ampDataAvgStruct2.(['avgWind' num2str(avgingWindows(1)*10^9) 'ns']) = ampDataAvgMat2;
        dataMax = max(ampDataAvgMat(:));
        dataMax2 = max(ampDataAvgMat2(:));
        %down sample the data.
        for avgdx = 2:length(avgingWindows)
            downSampleRate = avgingWindows(avgdx)/avgingWindows(1);
            
            oldSize = size(ampDataAvgMat);
            newSize = [oldSize(1) floor(oldSize(2)/downSampleRate)];
            newData = zeros(newSize);
            newData2 = zeros(newSize);
            
            for sampdx = 1:newSize(2)
                newData(:,sampdx) = mean(ampDataAvgMat(:,(1+(sampdx-1)*downSampleRate): (sampdx)*downSampleRate  )   ,2);
                newData2(:,sampdx) = mean(ampDataAvgMat2(:,(1+(sampdx-1)*downSampleRate): (sampdx)*downSampleRate  )   ,2);
            end
            ampDataAvgStruct.(['avgWind' num2str(avgingWindows(avgdx)*10^6) 'us']) = newData;
            ampDataAvgStruct2.(['avgWind' num2str(avgingWindows(avgdx)*10^6) 'us']) = newData2;
            
            newDataMax = max(newData(:));
            newDataMax2 = max(newData2(:));
            if newDataMax>dataMax;
                dataMax = newDataMax;
            end
            if newDataMax2>dataMax2;
                dataMax2 = newDataMax2;
            end
        end
        
        %final plots
        fieldVals = fields(ampDataAvgStruct);
        if strcmp(plotMode, 'multi')
            f = figure(77+pdx);
        else
            f = figure(77);
        end
        set(f, 'Position', [68 184 1531 926]);
        clf()
        p = uipanel('Parent',f,'BorderType','none');
        p.Title = filename;
        p.TitlePosition = 'centertop';
        p.FontSize = 12;
        p.FontWeight = 'bold';
        for windx = 1:length(avgingWindows)
            fieldName = fieldVals{windx};
            subplot(4,length(avgingWindows), windx, 'Parent',p)
            yaxis =1:numCardReads*cardparams.segments;
            xaxis =1:numDivisions(windx) *avgingWindows(windx)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgStruct.(fieldName));
            title(['traces : ' fieldName]);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(4,length(avgingWindows), length(avgingWindows)+windx, 'Parent',p)
            hist(    reshape(ampDataAvgStruct.(fieldName),1,numCardReads*cardparams.segments*numDivisions(windx)),numBins)
            xlim([0,dataMax])
            title(['histogram : ' fieldName])
            xlabel('homodyne amplitude')
            ylabel('occurences')
        end
        %second channel
        for windx = 1:length(avgingWindows)
            fieldName = fieldVals{windx};
            subplot(4,length(avgingWindows), 2*length(avgingWindows)+windx, 'Parent',p)
            yaxis =1:numCardReads*cardparams.segments;
            xaxis =1:numDivisions(windx) *avgingWindows(windx)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgStruct2.(fieldName));
            title(['traces2 : ' fieldName]);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(4,length(avgingWindows), 3*length(avgingWindows)+windx, 'Parent',p)
            hist(    reshape(ampDataAvgStruct2.(fieldName),1,numCardReads*cardparams.segments*numDivisions(windx)),numBins)
            xlim([0,dataMax2])
            title(['histogram2 : ' fieldName])
            xlabel('homodyne amplitude')
            ylabel('occurences')
        end
        
        
        
        %save data for each measurement configuration and each
        %power set point and acquisition setup
        %         saveFolder = ['Z:\Mattias\Data\tunableDimer\singleDriveHomodyne_' runDate '\'];
        %          saveFolder = ['Z:\Mattias\Data\tunableDimer\DualDriveCompareBistability_rightQubitDetuning_' runDate '\'];
        %          saveFolder = ['Z:\Mattias\Data\tunableDimer\DualDriveCompareBistability_LeftOutput_' runDate '\'];
        %          saveFolder = ['Z:\Mattias\Data\tunableDimer\singleDriveHomodyne_DualOutput_' runDate '\'];
        saveFolder = ['Z:\Mattias\Data\tunableDimer\dualDriveHomodyne_DualOutput_' runDate '\'];
        isFolder = exist(saveFolder);
        if isFolder == 0
            mkdir(saveFolder)
        end
        save([saveFolder filename '.mat'],...
            'CM','f0','fc','drive','ampDataAvgMat','config',...
            'cardparams', 'rfgen', 'logen', 'ampDataAvgStruct', 'avgingWindows', 'acquisitionPoints', ...
            'acq','numCardReads','vtraj','ampDataAvgMat2','ampDataAvgStruct2' )
        
        savefig(f, [saveFolder filename '.fig']);
        
        currFilePath = mfilename('fullpath');
        savePath = [saveFolder filename 'AK' '.mat'];
%         funclib.save_all(savePath, currFilePath);
        
        
        h = figure(99);
        set(f, 'Position', [68 184 1531 926]);
        clf()
        p = uipanel('Parent',h,'BorderType','none');
        p.Title = filename;
        p.TitlePosition = 'centertop';
        p.FontSize = 12;
        p.FontWeight = 'bold';
        for windx = 1:length(avgingWindows)
            fieldName = fieldVals{windx};
            subplot(2,length(avgingWindows), windx, 'Parent',p)
            yaxis =1:numCardReads*cardparams.segments;
            xaxis =1:numDivisions(windx) *avgingWindows(windx)*10^6;
            
%             Mat1 = ampDataAvgStruct.(fieldName);
%             Mat1 = Mat1 - min(Mat1(:));
%             Mat1 = Mat1/max(Mat1(:));
%             Mat2 = ampDataAvgStruct2.(fieldName);
%             Mat2 = Mat2 - min(Mat2(:));
%             Mat2 = Mat2/max(Mat2(:));
%             plotMat = Mat1 + Mat2;
            Mat1 = ampDataAvgStruct.(fieldName);
            threshold1 = mean(Mat1(:));
            Mat1 = Mat1 > threshold1;
            Mat2 = ampDataAvgStruct2.(fieldName);
            threshold2 = mean(Mat2(:));
            Mat2 = Mat2 > threshold2;
            plotMat = Mat1 + Mat2;
            
            imagesc(xaxis,yaxis,plotMat);
            title(['correlator matrix : ' fieldName]);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(2,length(avgingWindows), length(avgingWindows)+windx, 'Parent',p)
            hist(    reshape(plotMat,1,numCardReads*cardparams.segments*numDivisions(windx)),numBins)
            xlim([0,2])
            title(['corltn histogram : ' fieldName])
            xlabel('contrast of amplitude')
            ylabel('occurences')
        end
        savefig(h, [saveFolder filename '_corr.fig']);
        
        
        avgOutput1(pdx) = mean(ampDataAvgMat(:));
        avgOutput2(pdx) = mean(ampDataAvgMat2(:));
        % plot a figure of the avg output homodyne
        h = figure(99);
        set(f, 'Position', [68 184 1531 926]);
        clf()
        subplot(2,1,1);
        plot(drive.powerSetPoints(1:pdx),avgOutput1(1:pdx));
        xlabel('Drive Power [dBm]');
        ylabel('Avg Homodyne Amplitude');
        title([config.name ', Left Output'])
        
        subplot(2,1,2);
        plot(drive.powerSetPoints(1:pdx),avgOutput2(1:pdx));
        xlabel('Drive Power [dBm]');
        ylabel('Avg Homodyne Amplitude');
        title('Left Output');
        
        
        savefig([saveFolder config.name '_avgAmp.fig']);
        
        
        
    end %end loop over power set points
    
    
end %end loop over all the acquisitions

fc.currentVoltage=[0 0 0];