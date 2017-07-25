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
transWaitTime=45;
pnax.params.start = 5.7e9;
pnax.params.stop = 6.0e9;

pnax.params.points = 3201;

powerVec = linspace(-45,5,44);

fResonance=[0.0143 0.275 0.0];
fDetuned=[-0.1 0.0091 0.0];

f = fResonance;
v=fc.calculateVoltagePoint(f);

% pnax.params.power = -35;
pnax.PowerOn()
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
ftrans = pnax.ReadAxis();

%% Transmission power scan

fc.currentVoltage=v;
tic; time=fix(clock);
transS21AlongTrajectoryAmp = zeros(length(powerVec),length(ftrans));
transS21AlongTrajectoryPhase = zeros(length(powerVec),length(ftrans));
for idx=1:length(powerVec)
    if idx==1
        tStart=tic;
        time=clock;
        filename=['PowerScan_rightandRightInput_rightOutput_detuned_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
    end
    % update flux/voltage
    pnax.params.power = powerVec(idx);
    % measure S21 and S41
    pnax.SetActiveTrace(1);
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    pnax.SetActiveTrace(1);
    [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
    
    transS21AlongTrajectoryAmp(idx,:)=data_transS21A;
    transS21AlongTrajectoryPhase(idx,:)=data_transS21P;
    
    figure(158);
    imagesc(ftrans/1e9,powerVec(1:idx),transS21AlongTrajectoryAmp(1:idx,:)); title(filename); ylabel('PNAX Power [dBm]');xlabel('S21 (Cross) Measurement');
    
    if idx==1
        deltaT=toc(tStart);
        estimatedTime=deltaT*length(powerVec);
        disp(['Estimated Time is '...
            num2str(estimatedTime/3600),' hrs, or '...
            num2str(estimatedTime/60),' min']);
        disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
            round(estimatedTime),'second'))]);
    end
end
pnaxSettings=pnax.params.toStruct();

saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\PNAX_Calibrations_072417\';
isFolder = exist(saveFolder);
if isFolder == 0
    mkdir(saveFolder) 
end
save([saveFolder filename '.mat'],...
    'CM','f0','fc','transWaitTime','pnaxSettings','ftrans','time','powerVec',...
    'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase')

title(filename)
savefig([saveFolder filename '.fig']);

% fc.visualizeTrajectories(vtraj,ftraj);
% title([filename '_traj'])
% savefig([saveFolder filename '_traj.fig']);
toc

fc.currentVoltage=[0 0 0];
