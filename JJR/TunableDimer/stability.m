%% frequency stabilization test
% code to park at j minimum and monitor the cavity frequency over 24 hour
% period to check for stability.

%% Setup
transWaitTime=10;
transparams.start = 5.82e9;
transparams.stop = 5.86e9;
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
tic
[transamp, transph, S41transamp, S41transph] = pnax.FastReadS21andS41Trans(transWaitTime);
toc
freqvector=pnax.GetAxis();
figure(56);subplot(2,1,1);plot(freqvector/1e9,transamp,'b',freqvector/1e9,S41transamp,'r');title('Amplitude - Through blue, Cross red');subplot(2,1,2);plot(freqvector/1e9,transph,'b',freqvector/1e9,S41transph,'r');

%% set up scan
pauseBetween=159; %seconds between each measurement


steps=480;points=pnax.transparams.points;freqvector=pnax.GetAxis();
stabilityAmp=zeros(steps,points);
stabilityPhase=zeros(steps,points);
S41stabilityAmp=zeros(steps,points);
S41stabilityPhase=zeros(steps,points);
for index=1:steps
    [transamp, transph, S41transamp, S41transph] = pnax.FastReadS21andS41Trans(transWaitTime);
    stabilityAmp(index,:)=transamp;
    stabilityPhase(index,:)=transph;
    S41stabilityAmp(index,:)=S41transamp;
    S41stabilityPhase(index,:)=S41transph;
    % display
    figure(158);subplot(1,2,1);
    imagesc(freqvector/1e9,[1,index],stabilityAmp(1:index,:)); title(['stability' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('Through Measurement');    subplot(1,2,2);
    imagesc(freqvector/1e9,[1,index],S41stabilityAmp(1:index,:)); title(['transAlongTrajectory' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('Cross Measurement');
    pause(pauseBetween);
    save(['stability' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'CM','f0','fc','transWaitTime','transparams','S41transparams','freqvector','time','steps',...
        'stabilityAmp','stabilityPhase','S41stabilityAmp','S41stabilityPhase');
end
figure();
toc
