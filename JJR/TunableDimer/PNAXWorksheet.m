%% PNAX worksheet - updated to work with latest version of github code.

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.0001;yoko1.rampinterval=.01;
yoko2.rampstep=.0001;yoko2.rampinterval=.01;
yoko3.rampstep=.0001;yoko3.rampinterval=.01;
% CM = [1 0 0;  0 1 0; 0 0 1;]
% f0 = [0; 0; 0;];

CM = [.0845 0 0;  0 0.5597 0; .5659 -.4699 2.3068;]
f0 = [0; -.1975; -.348;];
% f0 = [0; -.1975; -.1655;];   from before reboot
fc=fluxController(CM,f0);

%% Update and read transmission channel
pnax.SetActiveTrace(1);
transWaitTime=1;
pnax.params.start = 5.75e9;
pnax.params.stop = 5.95e9;
pnax.params.points = 1001;
pnax.params.power = -35;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
pause(transWaitTime);
ftrans = pnax.ReadAxis();
pnax.SetActiveTrace(1);
[data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
pnax.SetActiveTrace(2);
[data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
plot(ftrans,data_transS21A,'b',ftrans,data_transS41A,'r');
subplot(2,1,2);
plot(ftrans,data_transS21P,'b',ftrans,data_transS41P,'r');

%% Ramp voltages [yoko1 yoko2 yoko3]
fc.currentVoltage=[0 0 0];
% fc.currentVoltage=[-1.9077 .3529 .6116];
currentVoltage=fc.currentVoltage;currentFlux=fc.currentFlux;display(currentVoltage),display(currentFlux)

%% Ramp fluxes [left qubit, right qubit, coupler]
fc.currentFlux=[0 .1 0];
currentVoltage=fc.currentVoltage;currentFlux=fc.currentFlux;display(currentVoltage),display(currentFlux)

%% Generate flux trajectory (start flux, stop flux, steps)
clear vtraj ftraj
fstart=[-.4 0 0];fstop=[.1 0 0];fsteps=51;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);

%% Generate voltage trajectory (start voltage, stop voltage, steps)
% clear vtraj ftraj
% vtraj=fc.generateTrajectory([0 0 -.25],[0 0 .5],301);
% ftraj=fc.calculateFluxTrajectory(vtraj);
% fc.visualizeTrajectories(vtraj,ftraj);

%% Transmission scan along trajectory
tic; time=fix(clock);
steps=size(vtraj,2); points=pnax.params.points; freqvector=pnax.ReadAxis();
z = zeros(steps,points); transS21AlongTrajectoryAmp=z; transS21AlongTrajectoryPhase=z; transS41AlongTrajectoryAmp=z; transS41AlongTrajectoryPhase=z;
fc.currentVoltage=vtraj(:,1);
for index=1:steps
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
end
pnaxSettings=pnax.params.toStruct();
save([dataDirectory 'transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'CM','f0','fc','transWaitTime','pnaxSettings','ftrans','ftraj','vtraj','time','steps',...
        'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase','transS41AlongTrajectoryAmp','transS41AlongTrajectoryPhase');
fc.currentVoltage=[0 0 0];
figure();
toc


%%
figure();subplot(1,2,1);
imagesc(ftrans/1e9,vtraj(1,1:index),transS21AlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S21 (Cross) Measurement');
subplot(1,2,2);
imagesc(ftrans/1e9,vtraj(1,1:index),transS41AlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S41 (Through) Measurement');