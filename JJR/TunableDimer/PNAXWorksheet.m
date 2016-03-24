%% PNAX worksheet - currently a hybrid of Gengyan style code and old code for controlling pnax

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.0001;yoko1.rampinterval=.02;
yoko2.rampstep=.0001;yoko2.rampinterval=.02;
yoko3.rampstep=.0001;yoko3.rampinterval=.02;
CM = [1 0 0;  0 1 0; 0 0 1;]
f0 = [0; 0; 0;];
fc=fluxController(CM,f0);

%% Switch to transmission channel and update settings
waitTime=1;
transparams.start = 5.5e9;
transparams.stop = 6.0e9;
transparams.points = 6001;
transparams.power = -30;
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
[transamp, transph, S41transamp, S41transph] = pnax.FastReadS21andS41Trans(waitTime);
freqvector=pnax.GetAxis();
figure(56);subplot(2,1,1);plot(freqvector/1e9,transamp,'b',freqvector/1e9,S41transamp,'r');title('Amplitude - Through blue, Cross red');subplot(2,1,2);plot(freqvector/1e9,transph,'b',freqvector/1e9,S41transph,'r');


%% Switch to transmission channel and update settings
trans.freq.start = 5.5e9;
trans.freq.stop =6.0e9;
trans.freq.numPoints = 6001;
trans.v_freq = linspace(trans.freq.start,trans.freq.stop,trans.freq.numPoints);
trans.power = 0;
trans.IFBandwidth = 10e3;
trans.maxAverages = 10000;
trans.waitTime = 5;
JJR_specUpdateTransSettings(instr,transChannel,specChannel,trans);
pause(1);fprintf(instr.pnax, 'DISPlay:WINDow:Y:AUTO');
fprintf(instr.pnax, 'DISPlay:WINDow:Y:AUTO');pause(trans.waitTime);fprintf(instr.pnax, 'DISPlay:WINDow:Y:AUTO');
[transAmpLine,transPhaseLine] = read_PNAX_AmpAndPhase(instr, transChannel, 'transAmpTrace','transPhaseTrace');
figure(56);subplot(2,1,1);plot(trans.v_freq/1e9,transAmpLine);subplot(2,1,2);plot(trans.v_freq/1e9,transPhaseLine);

%% Ramp voltages [yoko1 yoko2 yoko3]
fc.currentVoltage=[0 0 0];
currentVoltage=fc.currentVoltage;currentFlux=fc.currentFlux;display(currentVoltage),display(currentFlux)

%% Ramp fluxes [left qubit, right qubit, coupler]
fc.currentFlux=[-2 .28 0];
currentVoltage=fc.currentVoltage;currentFlux=fc.currentFlux;display(currentVoltage),display(currentFlux)

%% Generate flux trajectory (start flux, stop flux, steps)
clear vtraj ftraj
% fstart=[-2 .28 -.7];fstop=[-2 .28 -.23];fsteps=401;
fstart=[0 0 .294];fstop=[0 0 .308];fsteps=201;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);

%% Generate voltage trajectory (start voltage, stop voltage, steps)
% clear vtraj ftraj
% vtraj=fc.generateTrajectory([0 0 -.06],[0 0 .15],101);
% ftraj=fc.calculateFluxTrajectory(vtraj);

%% Transmission scan along trajectory
time=fix(clock);
steps=size(vtraj,2);
transAlongTrajectoryAmp=zeros(steps,trans.freq.numPoints);
transAlongTrajectoryPhase=zeros(steps,trans.freq.numPoints);
fc.currentVoltage=vtraj(:,1);
for index=1:steps
    % update flux/voltage
    fc.currentVoltage=vtraj(:,index);
    JJR_specUpdateTransSettings(instr,transChannel,specChannel,trans);
    % measure trans
    pause(trans.waitTime);
    [transAmpLine,transPhaseLine] = read_PNAX_AmpAndPhase(instr, transChannel, 'transAmpTrace','transPhaseTrace');
    transAlongTrajectoryAmp(index,:)=transAmpLine;
    transAlongTrajectoryPhase(index,:)=transPhaseLine;
    % display
    figure(158);
    imagesc(trans.v_freq/1e9,[1,index],transAlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');
end
save(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'CM','f0','fc','trans','ftraj','vtraj','time','steps',...
        'transAlongTrajectoryAmp','transAlongTrajectoryPhase');
fc.currentVoltage=[0 0 0];
figure();
imagesc(trans.v_freq/1e9,ftraj(3,:),transAlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('flux');
%%
figure();
imagesc(trans.v_freq/1e9,ftraj(3,:),transAlongTrajectoryAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('flux');

