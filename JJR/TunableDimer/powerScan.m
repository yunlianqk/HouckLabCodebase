%% power scan of s21 and s41 transmission
% simple

%% setup
startPower=-10;
stopPower=-50;
steps=81;

powerVector=linspace(startPower,stopPower,steps);

tic;
time=fix(clock);
points=pnax.transparams.points;freqvector=pnax.GetAxis();
powerScanAmp=zeros(steps,points);
powerScanPhase=zeros(steps,points);
S41powerScanAmp=zeros(steps,points);
S41powerScanPhase=zeros(steps,points);
for index=1:steps
    % update power
    transparams.power = powerVector(index);
    pnax.transparams = transparams;
    pnax.SetActiveTrace(1);pnax.SetTransParams();
    S41transparams=transparams;
    S41transparams.trace=5;
    S41transparams.meastype='S41';
    S41transparams.format = 'MLOG';
    pnax.S41transparams = S41transparams;
    pnax.SetActiveTrace(5);pnax.SetS41TransParams();
    [transamp, transph, S41transamp, S41transph] = pnax.FastReadS21andS41Trans(transWaitTime);
    powerScanAmp(index,:)=transamp;
    powerScanPhase(index,:)=transph;
    S41powerScanAmp(index,:)=S41transamp;
    S41powerScanPhase(index,:)=S41transph;
    % display
    figure(158);subplot(1,2,1);
    imagesc(freqvector/1e9,[1,index],powerScanAmp(1:index,:)); title(['powerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S21 Left cavity output');
    subplot(1,2,2);
    imagesc(freqvector/1e9,[1,index],S41powerScanAmp(1:index,:)); title(['powerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('step');xlabel('S41 Right cavity output');
end
save(['powerScan' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'CM','f0','fc','transWaitTime','transparams','S41transparams','freqvector','time','steps',...
        'powerScanAmp','powerScanPhase','S41powerScanAmp','S41powerScanPhase');
% fc.currentVoltage=[0 0 0];
figure();
toc