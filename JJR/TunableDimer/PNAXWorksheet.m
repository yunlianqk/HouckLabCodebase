%% PNAX worksheet - updated to work with latest version of github code.

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.001;yoko1.rampinterval=.01;
yoko2.rampstep=.001;yoko2.rampinterval=.01;
yoko3.rampstep=.0001;yoko3.rampinterval=.01;
% CM = [1 0 0;  0 1 0; 0 0 1;]
% f0 = [0; 0; 0;];

% CM = [.0845 -.00037 -.011; -.0034 0.5597 .0117; .5659 -.4699 2.3068;]
% CM = [.0845 -.00037 -.011; -.0034 0.5597 .0117; .5659 -.4699 2.3188;] % update on 09/09
CM = [.0845 -.00037 -.011; -.0034 0.5597 .0117; .5659 -.4699 2.3447;] % update on 09/10
% f0 = [.2748; -.1975; 0.2319;]; % after power surge 7/18
f0 = [.2748; -.1975; 0.1429;]; % after power surge 9/10
% f0 = [0; -.1975; -.348;]; % from reboot before power surge
% f0 = [0; -.1975; -.1655;];   from before reboot
fc=fluxController(CM,f0);

%% Update and read transmission channel
pnax.SetActiveTrace(1);
transWaitTime=10;
pnax.params.start = 5.75e9;
pnax.params.stop = 5.95e9;
pnax.params.points = 3001;
pnax.params.power = -33;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
% pause(transWaitTime);
ftrans = pnax.ReadAxis();
% pnax.SetActiveTrace(1);
% [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
% pnax.SetActiveTrace(2);
% [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
% figure();
% subplot(2,1,1);
% plot(ftrans,data_transS21A,'b',ftrans,data_transS41A,'r');
% % plot(ftrans,data_transS21A,'b');
% subplot(2,1,2);
% plot(ftrans,data_transS21P,'b',ftrans,data_transS41P,'r');

% %% Ramp voltages [yoko1 yoko2 yoko3]
% fc.currentVoltage=[0.296 0.883 .1628];
% % fc.currentVoltage=[-1.9077 .3529 .6116];
% currentVoltage=fc.currentVoltage;currentFlux=fc.currentFlux;display(currentVoltage),display(currentFlux)
% figure()
% %% Ramp fluxes [left qubit, right qubit, coupler]
% % fc.currentFlux=[0 .3686 0];
% fc.currentFlux=[0 0 0];
% currentVoltage=fc.currentVoltage;currentFlux=fc.currentFlux;display(currentVoltage),display(currentFlux)
% figure()
%% Generate flux trajectory (start flux, stop flux, steps)
% clear vtraj ftraj
% % fstart=[.2748 -.1975 -.75];fstop=[.2748 -.1975 .75];fsteps=501;
% fstart=[0.2748 -.1975 -0.5];fstop=[0.2748 -0.1975 0.5];fsteps=501;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
% ftraj=fc.calculateFluxTrajectory(vtraj);
% fc.visualizeTrajectories(vtraj,ftraj);
% 
%% Generate voltage trajectory (start voltage, stop voltage, steps)
clear vtraj ftraj
vtraj=fc.generateTrajectory([-3.1546 0.3183 0.0],[-3.1546 0.3183 0.2],20);
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
    [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();

    transS21AlongTrajectoryAmp(index,:)=data_transS21A;
    transS21AlongTrajectoryPhase(index,:)=data_transS21P;
    transS41AlongTrajectoryAmp(index,:)=data_transS41A;
    transS41AlongTrajectoryPhase(index,:)=data_transS41P;
    % display
    figure(158);subplot(1,2,1);
    imagesc(ftrans/1e9,[1,index],transS21AlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S21 (Cross) Measurement');
    subplot(1,2,2);
    imagesc(ftrans/1e9,[1,index],transS41AlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S41 (Through) Measurement');
    
    if index==1
        deltaT=toc(tStart);
        estimatedTime=steps*deltaT;
        disp(['Estimated Time is '...
            num2str(estimatedTime/3600),' hrs, or '...
            num2str(estimatedTime/60),' min']);
        disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
            round(estimatedTime),'second'))]);
    end
end
pnaxSettings=pnax.params.toStruct();
dailyDataDirectory='C:/Data/transmissionScans_I5_091016/';
mkdir(dailyDataDirectory)
filename=['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
save([dailyDataDirectory filename '.mat'],...
        'CM','f0','fc','transWaitTime','pnaxSettings','ftrans','ftraj','vtraj','time','steps',...
        'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase','transS41AlongTrajectoryAmp','transS41AlongTrajectoryPhase');
% fc.currentVoltage=[0 0 0];
savefig([dailyDataDirectory filename '.fig']);
title(filename)
% figure();
toc


% %%
% figure();subplot(1,2,1);
% imagesc(ftrans/1e9,ftraj(3,1:index),transS21AlongTrajectoryAmp(1:index-1,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S21 (Cross) Measurement');
% subplot(1,2,2);
% imagesc(ftrans/1e9,ftraj(3,1:index),transS41AlongTrajectoryAmp(1:index-1,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S41 (Through) Measurement');