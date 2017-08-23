%% Open PNAX 
address = 'GPIB0::16::0::INSTR'; % GPIB address for PNAX
pnax = PNAXAnalyzer(address);

%% Delete everything
pnax.DeleteAll();

%% Set channel 1 parameters for transmission S21
transCh1 = paramlib.pnax.trans();
% transCh1.start = 5.72428e9;
% transCh1.stop = 6.49351e9;

transCh1.start = 10e6;
transCh1.stop = 11.0e9;
transCh1.points = 4001;
transCh1.averages = 70;
transCh1.ifbandwidth = 1000;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';

pnax.SetParams(transCh1);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();


params.WaitTime = 10;

transCh1.power = -40;

filename=['outputB_30dBadditionalAttenuation_ColdAmpB_inputPower' num2str(transCh1.power) ];
pnax.SetParams(transCh1);
pnax.AvgClear();
pause(params.WaitTime);
S21amp = pnax.Read();
S21freqvector = pnax.ReadAxis();
% Plot data
figure(71);
plot(S21freqvector/1e9, S21amp);
title([filename])

saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\lineCalibrations_080317\';
isFolder = exist(saveFolder);
if isFolder == 0
    mkdir(saveFolder)
end

savefig([saveFolder filename '.fig']);

save( [saveFolder filename '.mat'], 'params', 'S21amp', 'S21freqvector', 'transCh1');
savefig([filename '.fig'] )


%% Set channel 1 parameters for transmission S21
transCh1 = paramlib.pnax.trans();
% transCh1.start = 5.72428e9;
% transCh1.stop = 6.49351e9;

transCh1.start = 8.55e9;
transCh1.stop = 10.1e9;
transCh1.points = 1001;
transCh1.averages = 70;
transCh1.ifbandwidth = 1000;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';

pnax.SetParams(transCh1);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();
% Yoko Scan 
% params.yoko2vect = linspace(0,0.4,50);
params.powerVec = linspace(-50,-50,1);

params.WaitTime = 120;
S21amp = zeros(length(params.powerVec), transCh1.points);
time=clock;
filename=['PowerScan_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];

for i = 1:length(params.powerVec)
    transCh1.power = params.powerVec(i);
    pnax.SetParams(transCh1);
    pnax.AvgClear();
    pause(params.WaitTime);
    S21amp(i,:) = pnax.Read();
    S21freqvector = pnax.ReadAxis();
    % Plot data
    figure(71);
    imagesc(S21freqvector/1e9, params.powerVec(1:i), S21amp(1:i,:));
    
%     
%     if counter == 1;
%         deltaT = toc(tStart);
%         disp(['Estimated Time is ',...
%             num2str(length(freqVec)*length(rfgen.powVec)*deltaT/3600),' hrs']);
%     end
end

save( [filename '.mat'], 'params', 'S21amp', 'S21freqvector', 'transCh1');
savefig([filename '.fig'] )


%% Yoko Scan

transCh1 = paramlib.pnax.trans();
% transCh1.start = 5.72428e9;
% transCh1.stop = 6.49351e9;

transCh1.start = 3.7e9;
transCh1.stop = 7.0e9;
transCh1.points = 1201;
transCh1.averages = 70;
transCh1.ifbandwidth = 1000;
transCh1.power = -35;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';

pnax.SetParams(transCh1);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();
% Yoko Scan 
% params.yoko2vect = linspace(0,0.4,50);
params.yoko1vect = linspace(-1,-3.5,200);

params.WaitTime = 60;
S21amp = zeros(length(params.yoko1vect), transCh1.points);

for i = 1:length(params.yoko1vect)
    if i == 1
        tStart = tic;
        time = clock;
        filename=['yokoScan_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
    end
    
    yoko1.SetVoltage(params.yoko1vect(i));
    pnax.AvgClear();
    pause(params.WaitTime);
    S21amp(i,:) = pnax.Read();
    S21freqvector = pnax.ReadAxis();
    % Plot data
    figure(71);
    imagesc(S21freqvector/1e9, params.yoko1vect(1:i), S21amp(1:i,:));
    xlabel('Frequency [GHz]');
    ylabel('Yoko Voltage [V]');
    title(filename)
    
    if i == 1;
        deltaT = toc(tStart);
        disp(['Estimated Time is ',...
            num2str(length(params.yoko1vect)*deltaT/60),' mins or ', ...
            num2str(length(params.yoko1vect)*deltaT/3600),' hrs']);
    end
    
end

saveDirectory = 'D:\Users\Mattias\QUASIwQ\';
dataFolder = 'specScans_042817';
mkdir([saveDirectory dataFolder]); 
cd([saveDirectory dataFolder])
save( [filename '.mat'], 'params', 'S21amp', 'S21freqvector', 'transCh1');
savefig([filename '.fig'] )
% cd('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\Mattias')
%%
yoko1.SetVoltage(0);

%% Power Scan

transCh1 = paramlib.pnax.trans();
pnax.SetActiveTrace(1);
% transCh1.start = 5.72428e9;
% transCh1.stop = 6.49351e9;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.start =  3.85e9;
transCh1.stop = 7.25e9;
transCh1.points = 1201;
transCh1.averages = 120;
transCh1.ifbandwidth = 1000;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';

pnax.SetParams(transCh1);

pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();

yoko1.SetVoltage(-2);

params.powerVec = linspace(-80,5,24);

params.WaitTime = 30;
S21amp = zeros(length(params.powerVec), transCh1.points);

for i = 1:length(params.powerVec)
    if i == 1
        tStart = tic;
        time = clock;
        filename=['powerScan_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
    end
    
    pnax.params.power = params.powerVec(i);
    pnax.AvgClear();
    pause(params.WaitTime);
    S21amp(i,:) = pnax.Read();
    S21freqvector = pnax.ReadAxis();
    % Plot data
    figure(71);
    imagesc(S21freqvector/1e9, params.powerVec(1:i), S21amp(1:i,:));
    xlabel('Frequency [GHz]');
    ylabel('PNAX Power [dBm]');
    title(filename);
    set(gca, 'YDir', 'normal');
    
    if i == 1;
        deltaT = toc(tStart);
        disp(['Estimated Time is ',...
            num2str(length(params.powerVec)*deltaT/60),' mins or ', ...
            num2str(length(params.powerVec)*deltaT/3600),' hrs']);
    end
    
end

saveDirectory = 'D:\Users\Mattias\QUASIwQ\';
dataFolder = 'powerScans_042717';
mkdir([saveDirectory dataFolder]); 
cd([saveDirectory dataFolder])
save( [filename '.mat'], 'params', 'S21amp', 'S21freqvector', 'transCh1');
savefig([filename '.fig'] )

%% Set channel 1 parameters for transmission S21

powerVec=-55;
for idx = 1:length(powerVec)

transCh1 = paramlib.pnax.trans();
% transCh1.start = 5.72428e9;
% transCh1.stop = 6.49351e9;

transCh1.start = 4.0e9;
transCh1.stop = 7.5e9;
transCh1.points = 1201;
transCh1.averages = 700;
transCh1.ifbandwidth = 100;
transCh1.power = powerVec(idx);
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';

pnax.SetParams(transCh1);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();
% Yoko Scan 
% params.yoko2vect = linspace(0,0.4,50);
params.yoko1vect = linspace(1,-4,60);

params.WaitTime = 60;
S21amp = zeros(length(params.yoko1vect), transCh1.points);
time=clock;
filename=['yokoScan_' num2str(powerVec(idx)) num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
for i = 1:length(params.yoko1vect)
   yoko1.SetVoltage(params.yoko1vect(i));
   pnax.AvgClear();
   pause(params.WaitTime);
   S21amp(i,:) = pnax.Read();
   S21freqvector = pnax.ReadAxis();
    % Plot data
    figure(71); 
    imagesc(S21freqvector/1e9, params.yoko1vect(1:i), S21amp(1:i,:));
    xlabel('Frequency [GHz]');
    ylabel('Yoko Voltage [V]');
    title(filename)
end
save( [filename '.mat'], 'params', 'S21amp', 'S21freqvector', 'transCh1');
savefig([filename '.fig'] )
end

yoko1.SetVoltage(0);
% 
% yoko2.SetVoltage(-0.2);
% params.yoko1vect = linspace(3.5,1,75);
% S21amp = zeros(length(params.yoko1vect), transCh1.points);
% 
% for i = 1:length(params.yoko1vect)
%    yoko1.SetVoltage(params.yoko1vect(i));
%    pnax.AvgClear();
%    pause(params.WaitTime);
%    S21amp(i,:) = pnax.Read();
%    S21freqvector = pnax.ReadAxis();
%     % Plot data
%     figure(72); 
%     imagesc(S21freqvector/1e9, params.yoko1vect(1:i), S21amp(1:i,:));
% end
% save('YokoSweep1_yoko2_m02_Fine1.mat', 'params', 'S21amp', 'S21freqvector', 'transCh1');

% params.WaitTime = 217;
% S21amp = zeros(length(params.yoko2vect), transCh1.points);
% 
% for i = 1:length(params.yoko2vect)
%    yoko2.SetVoltage(params.yoko2vect(i));
%    pnax.AvgClear();
%    pause(params.WaitTime);
%    S21amp(i,:) = pnax.Read();
%    S21freqvector = pnax.ReadAxis();
%     % Plot data
%     figure(7); 
%     imagesc(S21freqvector/1e9, params.yoko2vect(1:i), S21amp(1:i,:));
% end
%%
yoko1.SetVoltage(0);
params.yoko2vect = linspace(-10,0,200);
params.WaitTime = 17;
S21amp2 = zeros(length(params.yoko2vect), transCh1.points);

for i = 1:length(params.yoko2vect)
   yoko2.SetVoltage(params.yoko2vect(i));
   pnax.AvgClear();
   pause(params.WaitTime);
   S21amp2(i,:) = pnax.Read();
   S21freqvector = pnax.ReadAxis();
    % Plot data
    figure(81); 
    imagesc(S21freqvector/1e9, params.yoko2vect(1:i), S21amp2(1:i,:));
    title('Sweep Yoko2');
end

yoko2.SetVoltage(0);
%% Set channel 2 paramters for transmission S13
transCh2 = transCh1;
transCh2.channel = 2;
transCh2.trace = 2;
transCh2.meastype = 'S13';
transCh2.format = 'UPH';

pnax.params = transCh2;

pnax.AvgOn();
pnax.TrigContinuous();

pause(3);
pnax.AutoScaleAll();
%% Hold triggers
pnax.TrigHold(1);
pnax.TrigHold(2);
%% Set channel 3 parameters for spectroscopy
specCh3 = paramlib.pnax.spec();
specCh3.channel = 3;
specCh3.trace = 4;
% Unspecified parameters will be set to default value
pnax.params = specCh3;
% Note that the trace number is NOT the "TR#" on the PNAX panel
pnax.AvgOn();
%% Set single parameter
pnax.SetActiveChannel(1);
pnax.params.start = 4e9;
pnax.TrigContinuous();

pnax.SetActiveTrace(2);
pnax.params.stop = 7e9;
pnax.TrigContinuous();

%% Read data

S21amp = pnax.Read();
S21freqvector = pnax.ReadAxis();

% Plot data
figure(2); hold on;
plot(S21freqvector/1e9, S21amp);


%% Close PNAX
pnax.TrigHoldAll();
pnax.PowerOff();
pnax.Finalize();