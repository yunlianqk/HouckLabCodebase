% simple pnax scan for spec power
startPower=10;
stopPower=-40;
steps=51;

powerVector=linspace(startPower,stopPower,steps);

tic;
time=fix(clock);
freqvector=pnax.ReadAxis();points=length(freqvector);
S21specPowerScanAmp=zeros(steps,points);
S21specPowerScanPhase=zeros(steps,points);
pnax.SetActiveTrace(3);

for index=1:steps
    % update power
    pnax.params.power = powerVector(index);
    pnax.SetActiveTrace(3);
    pnax.ClearChannelAverages(2);
    pause(specWaitTime);
    pnax.SetActiveTrace(3);
%     pnax.SetActiveTrace(4);
%     [data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();
    [data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();
    S21specPowerScanAmp(index,:)=data_specS21A;
    S21specPowerScanPhase(index,:)=data_specS21P;
    % display
    figure(258);
    imagesc(fspec/1e9,powerVector(1:index),S21specPowerScanAmp(1:index,:)); title(['specPowerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('power [db]');xlabel('S21 Left cavity output');
end
pnaxSettings=pnax.params.toStruct();
save(['C:/Data/specPowerScan' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'specWaitTime','pnaxSettings','fspec','time','steps',...
        'S21specPowerScanAmp','S21specPowerScanPhase','powerVector','transWaitTime');
% fc.currentVoltage=[0 0 0];
figure();
toc

