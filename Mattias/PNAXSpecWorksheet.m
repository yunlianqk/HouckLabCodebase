%% PNAX Spec Optimization Worksheet

%% Update and read transmission channel
pnax.SetActiveTrace(1);
transWaitTime=10;
pnax.params.start = 4.5e9;
pnax.params.stop = 6.0e9;
pnax.params.points = 1201;
pnax.params.power = -35;
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
pause(transWaitTime);

ftrans = pnax.ReadAxis();
pnax.SetActiveTrace(1);
[data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
figure();
plot(ftrans,data_transS21A,'b',ftrans,data_transS21A,'r');

%% Compensate Electrical Delay - needs to be updated
pnax.SetActiveTrace(1);
pnax.CompensateElectricalDelay()

%% find cavity peak frequency and optimal phase contrast bias point
transAmpLine = data_transS21A; transPhaseLine=data_transS21P;

% choose max for a transmission peak and min for a reflection dip!
[peakVal,peakInd] = max(transAmpLine); peakFreq = ftrans(peakInd);
% [peakVal,peakInd] = min(transAmpLine); peakFreq = trans.v_freq(peakInd);
figure(651);
subplot(2,1,1);plot(ftrans/1e9,transAmpLine);
title('Transmission [MLOG]')
hold on; plotlib.vline(peakFreq/1e9); hold off
subplot(2,1,2);plot(ftrans/1e9,transPhaseLine);
hold on; plotlib.vline(peakFreq/1e9); hold off
title('Transmission [Unwrapped phase]')


% hard code the steepest slope 
peakFreq = 5.7e9;


%% Set channel 3 parameters for spectroscopy
specCh2 = paramlib.pnax.spec();
specCh2.channel = 2;
specCh2.trace = 3;
% Unspecified parameters will be set to default value
pnax.params = specCh2;
% Note that the trace number is NOT the "TR#" on the PNAX panel
pnax.AvgOn();

%% Switch to spec channels and update settings

pnax.SetActiveTrace(3);
specWaitTime = 20;
pnax.params.cwpower = -35;
pnax.params.start =  4.5e9;
pnax.params.stop = 5.5e9;
% pnax.params.start =  3.2e9;
% pnax.params.stop = 3.4e9;
pnax.params.points = 1001;
% pnax.params.points = 1001;
pnax.params.specpower = -30;
pnax.params.averages = 10000;
pnax.params.ifbandwidth = 10e3;
pnax.params.cwfreq=peakFreq;
pnax.ClearChannelAverages(2);
pause(specWaitTime);

fspec = pnax.ReadAxis();
pnax.SetActiveTrace(3);
[data_specS21A data_specS21P] = pnax.ReadAmpAndPhase();
% pnax.SetActiveTrace(4);
% [data_specS41A data_specS41P] = pnax.ReadAmpAndPhase();
figure();
subplot(2,1,1);
% plot(fspec,data_specS21A,'b',fspec,data_specS41A,'r')
plot(fspec,data_specS21A);
% plot(fspec,data_specS41A);
subplot(2,1,2);
plot(fspec,data_specS21P);
% plot(fspec,data_specS41P);


%% Spec scan sweeping Yoko, also monitoring transmission

pnax.SetActiveTrace(1);
transwaitTime = 15;
specWaitTime = 120;


pnax.params.start =  3.5e9;
pnax.params.stop = 7.25e9;
pnax.params.power = -45;
% pnax.params.start =  3.2e9;
% pnax.params.stop = 3.4e9;
pnax.params.points = 1201;
% pnax.params.points = 1001;
pnax.params.averages = 10000;
pnax.params.ifbandwidth = 10e3;


params.yoko1vect = linspace(1.0,-7.5,20);
data_specS21A = zeros(length(params.yoko1vect), pnax.params.points);
data_specS21P = zeros(length(params.yoko1vect), pnax.params.points);

data_transS21A = zeros(length(params.yoko1vect), pnax.params.points);
data_transS21P = zeros(length(params.yoko1vect), pnax.params.points);

for i = 1:length(params.yoko1vect)
    if i == 1
        tStart = tic;
        time = clock;
        filename=['specScan_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
    end
    yoko1.SetVoltage(params.yoko1vect(i));
    
    pnax.SetActiveTrace(1);
    pnax.ClearChannelAverages(1);
    pause(transWaitTime);
    ftrans = pnax.ReadAxis();
    [data_transS21A(i,:) data_transS21P(i,:)] = pnax.ReadAmpAndPhase();
    
    pnax.SetActiveTrace(3);
    pnax.params.start =  3.5e9;
    pnax.params.stop = 7.25e9;
    pnax.params.specpower = -30;
    pnax.params.cwfreq=5.632e9;
    pnax.params.cwpower = -45;
    pnax.ClearChannelAverages(2);
    pause(specWaitTime);
    
    fspec = pnax.ReadAxis();
    [data_specS21A(i,:) data_specS21P(i,:)] = pnax.ReadAmpAndPhase();
    
    figure(99);
    
    subplot(2,2,1);
    imagesc(fspec/1e9,params.yoko1vect(1:i),data_specS21A(1:i,:));
    colorbar();
    xlabel('Spec Frequency [GHz]');
    ylabel('Yoko Voltage [V]');
    title([filename ', Spec Amp, cwFreq=' num2str(pnax.params.cwfreq/1e9) '']);
    
    subplot(2,2,2);
    imagesc(ftrans/1e9,params.yoko1vect(1:i),data_transS21A(1:i,:));
    colorbar();
    xlabel('Trans Frequency [GHz]');
    ylabel('Yoko Voltage [V]');
    title('S21 Amplitude');
    
    subplot(2,2,3);
    imagesc(fspec/1e9,params.yoko1vect(1:i),data_specS21P(1:i,:));
    colorbar();
    xlabel('Spec Frequency [GHz]');
    ylabel('Yoko Voltage [V]');
    title('Spec Phase');
    
    subplot(2,2,4)
    imagesc(ftrans/1e9,params.yoko1vect(1:i),data_transS21A(1:i,:));
    colorbar();
    xlabel('Trans Frequency [GHz]');
    ylabel('Yoko Voltage [V]');
    title('S21 Phase');
    
    if i == 1;
        deltaT = toc(tStart);
        disp(['Estimated Time is ',...
            num2str(length(params.yoko1vect)*deltaT/60),' mins or ', ...
            num2str(length(params.yoko1vect)*deltaT/3600),' hrs']);
    end
    
end

saveDirectory = 'D:\Users\Mattias\QUASIwQ\';
dataFolder = 'specScans_042717';
mkdir([saveDirectory dataFolder]); 
cd([saveDirectory dataFolder])
save( [filename '.mat'], 'params', 'S21amp', 'S21freqvector', 'transCh1');
savefig([filename '.fig'] )


