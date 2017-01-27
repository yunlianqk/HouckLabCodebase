% TWPA bias optimization

pnax = PNAXAnalyzer(16);
gen = E8267DGenerator(24);

%% set pump parameters
gen.freq = 8.242e9;
gen.power = 12.83;
%%
gen.PowerOn()
%%
gen.PowerOff()
%% Update and read transmission channel
pnax.SetActiveTrace(1);
transWaitTime=5;
pnax.params.start = 10.1e9;
pnax.params.stop = 	10.25e9;
pnax.params.points = 3001;
pnax.params.power = -20;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 5e3;
pnax.ClearChannelAverages(1);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();
pnax.AutoScaleAll();
pause(transWaitTime);
ftrans = pnax.ReadAxis();
pnax.SetActiveTrace(1);
%%
[data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
plot(ftrans,data_transS21A,'b');
subplot(2,1,2);
plot(ftrans,data_transS21P,'b');
%%
pnax.AutoScaleAll();
%% generator power scan
transWaitTime = 30;
startPower=12.5;
stopPower=13.5;
steps=101;

powerVector=linspace(startPower,stopPower,steps);
tic;
time=fix(clock);
freqvector=pnax.ReadAxis();points=length(freqvector);
S21powerScanAmp=zeros(steps,points);
S21powerScanPhase=zeros(steps,points);
pnax.SetActiveTrace(1);
for index=1:steps
    % update generator power
    gen.power = powerVector(index);
    pnax.SetActiveTrace(1);
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
    S21powerScanAmp(index,:)=data_transS21A;
    S21powerScanPhase(index,:)=data_transS21P;
    % display
    figure(158);subplot(1,2,1);
    imagesc(freqvector/1e9,powerVector(1:index),S21powerScanAmp(1:index,:)); title(['powerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('power [db]');xlabel('Amplitude');
    subplot(1,2,2);
    imagesc(freqvector/1e9,powerVector(1:index),S21powerScanPhase(1:index,:)); title(['powerScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('power [db]');xlabel('Phase');
end
pnaxSettings=pnax.params.toStruct();
save(['C:/Data/TWPA_powerScan' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'transWaitTime','pnaxSettings','freqvector','time','steps',...
        'S21powerScanAmp','S21powerScanPhase','powerVector','gen');
figure();
toc
gen.PowerOff();
pnax.TrigHold(1);

%% generator frequency scan
transWaitTime = 20;
startFreq=8.2e9;
stopFreq=8.3e9;
steps=101;

pumpFreqVector=linspace(startFreq,stopFreq,steps);
tic;
time=fix(clock);
freqvector=pnax.ReadAxis();points=length(freqvector);
S21powerScanAmp=zeros(steps,points);
S21powerScanPhase=zeros(steps,points);
pnax.SetActiveTrace(1);
for index=1:steps
    % update generator freq
    gen.freq = pumpFreqVector(index);
    pnax.SetActiveTrace(1);
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
    S21powerScanAmp(index,:)=data_transS21A;
    S21powerScanPhase(index,:)=data_transS21P;
    % display
    figure(158);subplot(1,2,1);
    imagesc(freqvector/1e9,pumpFreqVector(1:index),S21powerScanAmp(1:index,:)); title(['pumpFreqScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('pump freq');xlabel('Amplitude');
    subplot(1,2,2);
    imagesc(freqvector/1e9,pumpFreqVector(1:index),S21powerScanPhase(1:index,:)); title(['pumpFreqScan ' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat']); ylabel('pump freq');xlabel('Phase');
end
pnaxSettings=pnax.params.toStruct();
save(['C:/Data/TWPA_pumpFreqScan' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'transWaitTime','pnaxSettings','freqvector','time','steps',...
        'S21powerScanAmp','S21powerScanPhase','pumpFreqVector','gen');
figure();
toc

%% 
figure();
imagesc(freqvector,powerVector,S21powerScanAmp(:,350:500))
% plot(S21powerScanAmp(:,350:500)')
% plot(powerVector,freqvector,S21powerScanPhase(:,350:500)')
%%
figure();
imagesc(freqvector,powerVector,10.^(S21powerScanAmp./10))