% simple pnax power scan of s21 and s41 transmission
transWaitTime = 1;
startPower=-30;
stopPower=-50;
steps=21;

powerVector=linspace(startPower,stopPower,steps);

tic;
time=fix(clock);
freqvector=pnax.ReadAxis();points=length(freqvector);
S21powerScanAmp=zeros(steps,points);
S21powerScanPhase=zeros(steps,points);
S41powerScanAmp=zeros(steps,points);
S41powerScanPhase=zeros(steps,points);
pnax.SetActiveTrace(1);
for index=1:steps
    % update power
    pnax.params.power = powerVector(index);
    pnax.SetActiveTrace(1);
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    pnax.SetActiveTrace(1);
    [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
    pnax.SetActiveTrace(2);
    [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
    S21powerScanAmp(index,:)=data_transS21A;
    S21powerScanPhase(index,:)=data_transS21P;
    S41powerScanAmp(index,:)=data_transS41A;
    S41powerScanPhase(index,:)=data_transS41P;
    % display
    figure(158);subplot(1,2,1);
    imagesc(freqvector/1e9,powerVector(1:index),S21powerScanAmp(1:index,:)); title(['powerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('power [db]');xlabel('S21 Left cavity output');
    subplot(1,2,2);
    imagesc(freqvector/1e9,powerVector(1:index),S41powerScanAmp(1:index,:)); title(['powerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('power [db]');xlabel('S41 Right cavity output');
end
pnaxSettings=pnax.params.toStruct();
save([dataDirectory 'powerScan' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'CM','f0','fc','transWaitTime','pnaxSettings','freqvector','time','steps',...
        'S21powerScanAmp','S21powerScanPhase','S41powerScanAmp','S41powerScanPhase','powerVector');
% fc.currentVoltage=[0 0 0];
figure();
toc
%%
figure(158);subplot(1,2,1);
imagesc(freqvector/1e9,powerVector(1:index),S21powerScanAmp(1:index,:)); title(['powerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('power [db]');xlabel('S21 Left cavity output');
subplot(1,2,2);
imagesc(freqvector/1e9,powerVector(1:index),S41powerScanAmp(1:index,:)); title(['powerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('power [db]');xlabel('S41 Right cavity output');
%%
figure();
plot(freqvector/1e9,S41powerScanAmp(:,:))