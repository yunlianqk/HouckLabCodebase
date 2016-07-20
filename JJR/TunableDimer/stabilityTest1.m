%% see notes in 3/29/16 page of notebook
% stabilityTest1 is code to prove I'm moving the coupler yoko slowly enough
% to not cause jumping.
% runs a transmission scan then sweeps back and forth at varying
% speeds to try to induce a jump.  As this speed is increased I expect to see jumping.

%%  setup vector of ramp speeds
% yoko3 rampstep is set to minimum of .0001 for the voltage range I'm using
yoko3IntervalVector = [.1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1];

%% setup yoko settings for transmission scan (should be slow enough to not cause a jump during scan)
scanYoko3RampStep = .0001;
scanYoko3RampInterval = .1;

%% setup transmission channel
transWaitTime=5;
transparams.start = 5.81e9;
transparams.stop = 5.95e9;
transparams.points =1001;
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

%% Setup flux controller
% don't use cross coupling
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.0003;yoko1.rampinterval=.005;
yoko2.rampstep=.0002;yoko2.rampinterval=.01;
yoko3.rampstep=scanYoko3RampStep;yoko3.rampinterval=scanYoko3RampInterval;
CM = [1 0 0;  0 1 0; 0 0 1;];
f0 = [0; 0; 0;];
fc=fluxController(CM,f0);

%% voltage trajectory for scan
clear vtraj ftraj
% vtraj=fc.generateTrajectory([0 0  -0.1888],[0 0 -0.0638],201);
% vtraj=fc.generateTrajectory([0 0 -.1175],[0 0 -.1025],151);
vtraj=fc.generateTrajectory([0 0  -0.12],[0 0 0.25],201);
ftraj=fc.calculateFluxTrajectory(vtraj);
fc.visualizeTrajectories(vtraj,ftraj);

%% run scan
time=fix(clock);
% setup data structures for storing
speedSteps = length(yoko3IntervalVector);
trajectorySteps = size(vtraj,2);
points=pnax.transparams.points;
freqvector=pnax.GetAxis();
stabilityTest1Data=zeros(speedSteps,trajectorySteps,points);
stabilityTest1DataPeaks=zeros(speedSteps,trajectorySteps);
tic
% move to start of trajectory using 1st speed in vector
yoko3.rampstep=scanYoko3RampStep;
yoko3.rampinterval=yoko3IntervalVector(1);
fc.currentVoltage=vtraj(:,1);
for index1=1:speedSteps
    % set yoko3 for slow transmission scan
    yoko3.rampstep=scanYoko3RampStep;
    yoko3.rampinterval=scanYoko3RampInterval;
    % run transmission scan
    for index2=1:trajectorySteps
        % update flux/voltage
        fc.currentVoltage=vtraj(:,index2);
        % read s41 amplitude
        pnax.SetActiveTrace(5);
        pnax.ClearChannelAverages(pnax.S41transchannel);
        pause(transWaitTime);
        S41transamp=pnax.Read();
        stabilityTest1Data(index1,index2,:)=S41transamp;
        [c,peakInd]=max(S41transamp);
        stabilityTest1DataPeaks(index1,index2)=freqvector(peakInd);
        % display
        figure(158);
        subplot(1,2,1)
        imagesc(freqvector/1e9,[1,index2],squeeze(stabilityTest1Data(index1,1:index2,:))); title(['stabilityTest1' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('right cavity through');
        subplot(1,2,2)
        plot([1:index2],stabilityTest1DataPeaks(index1,1:index2));
    end
    %add latest peak data to running plot
    figure(159);
    plot([1:trajectorySteps],stabilityTest1DataPeaks(1:index1,:));
    % save data
    save(['stabilityTest1' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'yoko3IntervalVector','scanYoko3RampStep','scanYoko3RampInterval','CM','f0','fc',...
        'transWaitTime','transparams','S41transparams','freqvector','ftraj','vtraj',...
        'time','speedSteps','trajectorySteps','stabilityTest1Data','stabilityTest1DataPeaks');
    % sweep yoko3 around at speed given by yoko3IntervalVector
    yoko3.rampinterval=yoko3IntervalVector(index1);
%     fc.currentVoltage=[0 0 -1];
%     fc.currentVoltage=[0 0 1];
    fc.currentVoltage=vtraj(:,1);
    toc
end
figure()
toc
%%
figure();
% imagesc([-0.1888 -0.0638],[1 40],stabilityTest1DataPeaks)
imagesc(stabilityTest1DataPeaks(1:35,:))


