<<<<<<< HEAD
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
transWaitTime=20;
pnax.params.start = 5.7e9;
pnax.params.stop = 6.0e9;

pnax.params.points = 2201;

powerVec = linspace(-45,5,20);


fResonanceLargeJ=[0.0143 0.275 0.0];
fResonanceSmallJ=[0.0143 0.275 0.35];
fDetunedLargeJ=[-0.1 0.0091 0.0];
fDetunedSmallJ=[-0.1 0.0091 0.35];

% pnax.params.power = -35;
pnax.PowerOn()
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
ftrans = pnax.ReadAxis();

%% Transmission power scan

for tdx = 3:4
    
    if tdx==1
        v = fc.calculateVoltagePoint(fResonanceLargeJ);
    elseif tdx==2
        v = fc.calculateVoltagePoint(fResonanceSmallJ);
    elseif tdx==3
        v = fc.calculateVoltagePoint(fDetunedLargeJ);
    elseif tdx ==4
        v = fc.calculateVoltagePoint(fDetunedSmallJ);
    end
    
    fc.currentVoltage=v;
    tic; time=fix(clock);
    transS21AlongTrajectoryAmp = zeros(length(powerVec),length(ftrans));
    transS21AlongTrajectoryPhase = zeros(length(powerVec),length(ftrans));
    for idx=1:length(powerVec)
        if idx==1
            tStart=tic;
            time=clock;
            if tdx==1
                filename=['PowerScan_rightInput_rightOutput_fResonanceLargeJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
            elseif tdx==2
                filename=['PowerScan_rightInput_rightOutput_fResonanceSmallJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
            elseif tdx==3
                filename=['PowerScan_leftInput_rightOutput_fDetunedLargeJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
            elseif tdx ==4
                filename=['PowerScan_leftInput_rightOutput_fDetunedSmallJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
            end
            
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
            estimatedTime=deltaT*length(powerVec)*4;
            disp(['Estimated Time is '...
                num2str(estimatedTime/3600),' hrs, or '...
                num2str(estimatedTime/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(estimatedTime),'second'))]);
        end
    end
    pnaxSettings=pnax.params.toStruct();
    
    saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\PNAX_Calibrations_072517\';
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
    
end
fc.currentVoltage=[0 0 0];
=======
addpath('C:\Users\BFG\Documents\HouckLabMeasurementCode\JJR\TunableDimer')

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
CM = [0.07512 0 0; 0 0.9198/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated left and right qubit diagonal elements at 9:30 am on 8/17/17 

f0 = [0; -0.2; -0.05]; % updated 08/17/17 at 12 pm
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
% transWaitTime=10;
transWaitTime=10;
pnax.params.start = 5.8e9;
pnax.params.stop = 5.95e9;

pnax.params.points = 2201;

% powerVec = linspace(-55,-10,20);
powerVec = linspace(-65,-10,25);


fResonanceLargeJ=[-0.088 0.28 0.0];
fResonanceSmallJ=[-0.088 0.28 0.35];
fDetunedLargeJ=[0.22 0.5 0.0];
fDetunedSmallJ=[0.22 0.5 0.35];

% pnax.params.power = -35;
pnax.PowerOn()
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
ftrans = pnax.ReadAxis();

%% Transmission power scan

% for tdx = [1 3]
for tdx = [2 4]
    
    if tdx==1
        v = fc.calculateVoltagePoint(fResonanceLargeJ)
    elseif tdx==2
        v = fc.calculateVoltagePoint(fResonanceSmallJ)
    elseif tdx==3
        v = fc.calculateVoltagePoint(fDetunedLargeJ)
    elseif tdx ==4
        v = fc.calculateVoltagePoint(fDetunedSmallJ)
    end
    
    voltageCutoff = 3.5;
    
    if abs(v)>voltageCutoff
        disp('VOLTAGE IS TOO HIGH')
        return
    end
    
    fc.currentVoltage=v;
    tic; time=fix(clock);
    transS21AlongTrajectoryAmp = zeros(length(powerVec),length(ftrans));
    transS21AlongTrajectoryPhase = zeros(length(powerVec),length(ftrans));
    transS41AlongTrajectoryAmp = zeros(length(powerVec),length(ftrans));
    transS41AlongTrajectoryPhase = zeros(length(powerVec),length(ftrans));
    for idx=1:length(powerVec)
        if idx==1
            tStart=tic;
            time=clock;
            if tdx==1
                filename=['PowerScan_leftInput_rightOutput_fResonanceLargeJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
                fignum =41;
            elseif tdx==2
                filename=['PowerScan_leftInput_rightOutput_fResonanceSmallJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
                fignum = 44;
            elseif tdx==3
                filename=['PowerScan_leftInput_rightOutput_fDetunedLargeJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
                fignum = 47;
            elseif tdx ==4
                filename=['PowerScan_leftInput_rightOutput_fDetunedSmallJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
                fignum = 49;
            end
            
        end
        % update flux/voltage
        pnax.params.power = powerVec(idx);
        pnax.SetActiveTrace(1);
        pnax.ClearChannelAverages(1);
        pause(transWaitTime);
        pnax.SetActiveTrace(1);
        [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
        pnax.SetActiveTrace(2);
        pause(1);
        [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
        
        transS21AlongTrajectoryAmp(idx,:)=data_transS21A;
        transS21AlongTrajectoryPhase(idx,:)=data_transS21P;
        
        transS41AlongTrajectoryAmp(idx,:)=data_transS41A;
        transS41AlongTrajectoryPhase(idx,:)=data_transS41P;
        
        %         figure(158);
        %         imagesc(ftrans/1e9,powerVec(1:idx),transS21AlongTrajectoryAmp(1:idx,:)); title(filename); ylabel('PNAX Power [dBm]');xlabel('S21 (Cross) Measurement');
        %
        hFig = figure(fignum);
        set(hFig, 'Position', [100 100 1000 600]);
        subplot(1,2,1);
        imagesc(ftrans/1e9,powerVec(1:idx),transS21AlongTrajectoryAmp(1:idx,:)); title(filename); ylabel('step');xlabel('Right Output Frequency [GHz]');
        subplot(1,2,2);
        imagesc(ftrans/1e9,powerVec(1:idx),transS41AlongTrajectoryAmp(1:idx,:)); title(filename); ylabel('step');xlabel('Left Output Frequency [GHz]');
        
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
    
    saveFolder = 'C:\Users\BFG\Documents\Mattias\tunableDimer\PNAX_Calibrations_081718\';
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
    
    currFilePath = mfilename('fullpath');
    savePath = [saveFolder filename 'AK' '.mat'];
    % funclib.save_all(savePath);
    funclib.save_all(savePath, currFilePath);

    
end
fc.currentVoltage=[0 0 0];


% currFilePath = mfilename('fullpath');
% savePath = [saveFolder filename 'AK' '.mat'];
% % funclib.save_all(savePath);
% funclib.save_all(savePath, currFilePath);
>>>>>>> fcfd5e9cf561fc8f7ca51bf628e9d0c6f4f94fdd
