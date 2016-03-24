%% PNAX worksheet - currently a hybrid of Gengyan style code and old code for controlling pnax

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.0003;yoko1.rampinterval=.005;
yoko2.rampstep=.0002;yoko2.rampinterval=.01;
yoko3.rampstep=.0001;yoko3.rampinterval=.02;
CM = [1 0 0;  0 1 0; 0 0 1;]
f0 = [0; 0; 0;];
% CM = [.0845 0 0;  0 0.5597 0; .545 -.5092 2.3068;]
% f0 = [.1689; -0.1772; 0.1308;];
fc=fluxController(CM,f0);

%% Switch to transmission channel and update settings
transWaitTime=5;
transparams.start = 5.81e9;
transparams.stop = 5.87e9;
transparams.points =501;
transparams.power = -35;
transparams.averages = 65536;
transparams.ifbandwidth = 10e3;
transparams.trace = 1;
transparams.meastype = 'S21';
transparams.format = 'MLOG';
pnax.transparams = transparams;
pnax.SetActiveTrace(1);pnax.SetTransParams();
S41transparams=transparams;
S41transparams.trace=5;
S41transparams.meastype='S41';
S41transparams.format = 'MLOG';
pnax.S41transparams = S41transparams;
pnax.SetActiveTrace(5);pnax.SetS41TransParams();
[transamp, transph, S41transamp, S41transph] = pnax.FastReadS21andS41Trans(transWaitTime);
freqvector=pnax.GetAxis();
figure(56);subplot(2,1,1);plot(freqvector/1e9,transamp,'b',freqvector/1e9,S41transamp,'r');title('Amplitude - Through blue, Cross red');subplot(2,1,2);plot(freqvector/1e9,transph,'b',freqvector/1e9,S41transph,'r');


%% Ramp voltages [yoko1 yoko2 yoko3]
fc.currentVoltage=[0 0 0];
currentVoltage=fc.currentVoltage;currentFlux=fc.currentFlux;display(currentVoltage),display(currentFlux)

%% Ramp fluxes [left qubit, right qubit, coupler]
fc.currentFlux=[0 0 -.0326];
currentVoltage=fc.currentVoltage;currentFlux=fc.currentFlux;display(currentVoltage),display(currentFlux)

%% Generate flux trajectory (start flux, stop flux, steps)
clear vtraj ftraj
fstart=[0 0 -.05];fstop=[0 0 -.02];fsteps=401;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);

%% Generate voltage trajectory (start voltage, stop voltage, steps)
clear vtraj ftraj
vtraj=fc.generateTrajectory([0 0 -.08],[0 0 -.07],201);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);
%% Transmission scan along trajectory
tic;
time=fix(clock);
steps=size(vtraj,2);points=pnax.transparams.points;freqvector=pnax.GetAxis();
transAlongTrajectoryAmp=zeros(steps,points);
transAlongTrajectoryPhase=zeros(steps,points);
S41transAlongTrajectoryAmp=zeros(steps,points);
S41transAlongTrajectoryPhase=zeros(steps,points);
fc.currentVoltage=vtraj(:,1);
for index=1:steps
    % update flux/voltage
    fc.currentVoltage=vtraj(:,index);
    [transamp, transph, S41transamp, S41transph] = pnax.FastReadS21andS41Trans(transWaitTime);
    transAlongTrajectoryAmp(index,:)=transamp;
    transAlongTrajectoryPhase(index,:)=transph;
    S41transAlongTrajectoryAmp(index,:)=S41transamp;
    S41transAlongTrajectoryPhase(index,:)=S41transph;
    % display
    figure(158);subplot(1,2,1);
    imagesc(freqvector/1e9,[1,index],transAlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('Through Measurement');
    subplot(1,2,2);
    imagesc(freqvector/1e9,[1,index],S41transAlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('Cross Measurement');
end
save(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'CM','f0','fc','transWaitTime','transparams','S41transparams','freqvector','ftraj','vtraj','time','steps',...
        'transAlongTrajectoryAmp','transAlongTrajectoryPhase','S41transAlongTrajectoryAmp','S41transAlongTrajectoryPhase');
% fc.currentVoltage=[0 0 0];
figure();
toc
%%
figure();subplot(1,2,1);
imagesc(freqvector/1e9,ftraj(3,:),transAlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S21 (left cavity ouput)');
subplot(1,2,2);
imagesc(freqvector/1e9,ftraj(3,:),S41transAlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S41 (right cavity output)');

%%