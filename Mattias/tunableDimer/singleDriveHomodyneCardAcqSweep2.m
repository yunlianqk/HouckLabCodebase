
% funclib.clear_local_variables()

addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')

%%
time = clock;
runDate = datestr(time,'mmddyy');

%%
% %% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.002;yoko1.rampinterval=.01;
yoko2.rampstep=.002;yoko2.rampinterval=.01;
yoko3.rampstep=.002;yoko3.rampinterval=.01;

% CM = [1 0 0; 0 1 0; 0 0 1];  %starter Matrix
% CM = [1 0 0; 0 1 0; 1/2.5 60/136 1/0.45];  %iteration3
% CM = [1 0 0; 0 1 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated 8/12 to include qubit effects on coupler
% CM = [1 0 0; 0 1/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Changed the diagonal element for the right qubit
% CM = [0.07512 0 0; 0 0.9198/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated left and right qubit diagonal elements at 9:30 am on 8/17/17
CM = [0.07512 -0.009225 -0.001525; -0.003587 0.4841 0.002462; 0.4181 -0.4286 2.2222];  % Alicia update from scans over the past few days. Up 8/17/17


% f0 = [0; -0.2; -0.25]; % updated 08/17/17 at 12 pm
% f0 = [0; -0.2; -0.05]; % updated 08/17/17 at 12 pm
f0 = [0; -0.2; -0.1083]; % updated 08/22/17 at 6:30 pm
fc=fluxController(CM,f0);

fc2 = fluxController2;
EcLeft = 298e6;
EcRight = 298e6;
EjSumLeft = 25.420e9;
EjSumRight = 29.342e9;
fc2.leftQubitFluxToFreqFunc = @(x) sqrt(8.*EcLeft.*EjSumLeft.*abs(cos(pi.*x)))-EcLeft;
fc2.rightQubitFluxToFreqFunc = @(x) sqrt(8.*EcRight.*EjSumRight.*abs(cos(pi.*x)))-EcRight;

% added these as of 08/17/17
rightQubitMin=-0.48;
rightQubitResonance=-0.3;
rightQubitMax=0;

leftQubitMin=0.11;
leftQubitResonance=-0.088;
leftQubitMax=-0.22;

couplerMinJ=0.44;
couplerMaxJ=0; 


%%


% use the vtraj from matrixCalibration_rightInput_-25wAtten_20170823_1137
% fstart=[leftQubitMin (rightQubitResonance-0.15) couplerMinJ];
% fstop=[leftQubitMin (rightQubitResonance+0.15) couplerMinJ];fsteps=50;
% fstart=[leftQubitMin (rightQubitResonance-0.15) 0.22];
% fstop=[leftQubitMin (rightQubitResonance+0.15) 0.22];fsteps=40;
fstart=[leftQubitMin (rightQubitResonance-0.15) 0];
fstop=[leftQubitMin (rightQubitResonance+0.15) 0];fsteps=20;

vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
voltageCutoff = 3.5;

if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);

vtraj(:,9)
% fc.currentVoltage = vtraj(:,23); 
% fc.currentVoltage = vtraj(:,19); 

%%   set up all the different measurements
targetTimeDuration = 100e-6;
sampleinterval = 64e-9;

clear acquisitionPoints measurementPoint

%%%%max J
measurementPoint = {};
measurementPoint.name = 'maxJ';
measurementPoint.voltagePoint = [1.4290, -0.2435, -0.2671];
% measurementPoint.powerSetPoints = linspace(-45,-30,15);
measurementPoint.powerSetPoints = -32.5*ones(1,8);
measurementPoint.numReads = 5;
measurementPoint.probeFrequency = 5.909e9;
measurementPoint.averages = 6000;
acquisitionPoints(1) = measurementPoint;

% %%%max J2
% measurementPoint = {};
% measurementPoint.name = 'maxJ2';
% measurementPoint.voltagePoint = [1.4290, -0.2435, -0.2671];
% % measurementPoint.powerSetPoints = linspace(-45,-30,15);
% measurementPoint.powerSetPoints = -32*ones(1,16);
% measurementPoint.numReads = 200;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000;
% acquisitionPoints(2) = measurementPoint;

% %%%%largeJ
% measurementPoint = {};
% measurementPoint.name = 'largeJ';
% measurementPoint.voltagePoint = [1.4341, -0.2189, -0.1643];
% % measurementPoint.powerSetPoints = [-41, -40, -39, -38, -37, -36, -35]; %collumns
% % measurementPoint.powerSetPoints = [-38,-38, -37, -37, -36, -36];
% measurementPoint.powerSetPoints = -37*ones(1,16);
% measurementPoint.numReads = 200;
% measurementPoint.probeFrequency = 5.908e9;
% measurementPoint.averages = 6000;
% acquisitionPoints(3) = measurementPoint;
% 
% %%%%largeJ2
% measurementPoint = {};
% measurementPoint.name = 'largeJ2';
% measurementPoint.voltagePoint = [1.4341, -0.2189, -0.1643];
% % measurementPoint.powerSetPoints = [-41, -40, -39, -38, -37, -36, -35]; %collumns
% % measurementPoint.powerSetPoints = [-38,-38, -37, -37, -36, -36];
% measurementPoint.powerSetPoints = -38*ones(1,16);
% measurementPoint.numReads = 200;
% measurementPoint.probeFrequency = 5.908e9;
% measurementPoint.averages = 6000;
% acquisitionPoints(4) = measurementPoint;
% 
% %%%small J
% measurementPoint = {};
% measurementPoint.name = 'minJ';
% measurementPoint.voltagePoint = [1.4351, -0.2272, -0.0671];
% % measurementPoint.powerSetPoints = linspace(-29,-25,5);
% % measurementPoint.powerSetPoints = linspace(-29,-24,10);
% measurementPoint.powerSetPoints = -27*ones(1,16);
% measurementPoint.numReads = 200;
% measurementPoint.probeFrequency = 5.872e9;
% measurementPoint.averages = 6000;
% acquisitionPoints(5) = measurementPoint;
% 
% %%%small J2
% measurementPoint = {};
% measurementPoint.name = 'minJ2';
% measurementPoint.voltagePoint = [1.4351, -0.2272, -0.0671];
% % measurementPoint.powerSetPoints = linspace(-29,-25,5);
% % measurementPoint.powerSetPoints = linspace(-29,-24,10);
% measurementPoint.powerSetPoints = -26*ones(1,16);
% measurementPoint.numReads = 200;
% measurementPoint.probeFrequency = 5.872e9;
% measurementPoint.averages = 6000;
% acquisitionPoints(6) = measurementPoint;

%%


% %% Set AWG parameters
% triggen.period = 10e-6;
% % Time axis: 0.8 ns sampling interval, 5 us total length
% taxis = 0:0.8e-9:10e-6;
% pulsegen1.timeaxis = taxis;
% pulsegen1.waveform1 = ones(1,length(taxis));
% pulsegen1.waveform2 = pulsegen1.waveform1;
% pulsegen1.Generate();
% pulsegen1.marker2 = (taxis <= 200e-9).*(taxis > 100e-9);

% % Plot waveforms and markers
% figure(1);
% subplot(2, 1, 1);
% hold off;
% plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform1);
% hold on;
% plot(pulsegen1.timeaxis/1e-6, pulsegen1.marker2, 'r');
% title('Channel 1');
% legend('Waveform', 'Marker');
% subplot(2, 1, 2);
% hold off;
% plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform2/max(abs(pulsegen1.waveform2)));
% hold on;
% plot(pulsegen1.timeaxis/1e-6, pulsegen1.marker4, 'r');
% xlabel('Time (\mus)');
% title('Channel 2');

%% Set up Trigger

triggen.period = 10e-6;
triggen.offset=1;
triggen.vpp=2;
triggen.PowerOn();


%% Set up Generators

rfgen.ModOff();
logen.ModOff();

rfgen.PowerOn();

logen.power = 12.5;
logen.PowerOn();

corrparams.Int_Freq = 0e6;

rfgen.freq = 5.908e9;
logen.freq = rfgen.freq + corrparams.Int_Freq;

%% Set Up Card Parameters

cardparams = paramlib.acqiris();
cardparams.fullscale = 0.5;
cardparams.offset = 0e-6;

cardparams.sampleinterval = sampleinterval;
exponent = nextpow2(targetTimeDuration/cardparams.sampleinterval);
actualTimeDuration = (2^exponent)*cardparams.sampleinterval;
cardparams.samples = 2^exponent;
cardparams.averages = 4;
cardparams.segments = 1;
cardparams.delaytime = 1e-6;
cardparams.couplemode = 'DC';
corrparams.limCount=1;

triggen.period = actualTimeDuration+1e-6;
cardparams.trigPeriod = triggen.period;

card.SetParams(cardparams);

% Time axis in us
timeaxis = (0:card.params.samples-1)*card.params.sampleinterval/1e-6;

% %% Acquire test data
% 
% rfgen.power = -25;
% % specgen.power = -20;
% pause(0.01);
% 
% [Idata, Qdata] = card.ReadIandQ();
% 
% % Plot data
% figure(1);
% subplot(3,1,1);
% plot(timeaxis, Idata);
% title('In-phase');
% ylabel('V_I (V)');
% 
% subplot(3,1,2);
% plot(timeaxis, Qdata);
% ylabel('V_Q (V)');
% xlabel('Time (\mus)');
% 
% subplot(3,1,3);
% plot(timeaxis, Idata.^2+Qdata.^2);
% title('Amplitude');
% ylabel('V_Q (V)');
% xlabel('Time (\mus)');

%% loop over the different types of acqusitions
temp = size(acquisitionPoints);
numAcquisitions = temp(2);

exponent = nextpow2(targetTimeDuration/cardparams.sampleinterval);
actualTimeDuration = (2^exponent)*cardparams.sampleinterval;
cardparams.samples = 2^exponent;
triggen.period = actualTimeDuration+1e-6;
cardparams.trigPeriod = triggen.period;
card.SetParams(cardparams);


% avgingWindows = [2.5, 5, 10, 20, 50, 100]*1e-6;
avgingWindows = [2, 5, 10, 20]*1e-6; %%%%%!!!!!!!!!!!!!! must be integer divisions of target time duration
numDivisions = floor(targetTimeDuration./avgingWindows);
for acq = 1:numAcquisitions
    config = acquisitionPoints(acq);
    numReads = config.numReads; %number of card acquisitions
    drive.powerSetPoints = config.powerSetPoints;
    
    fc.currentVoltage = config.voltagePoint; 

    ampDataAvgMat = zeros(length(drive.powerSetPoints),numReads*numDivisions(1));
   
    
    %set the frequency of the rf gan for this measurement
    rfgen.freq = config.probeFrequency;
    logen.freq = rfgen.freq;
    
    for pdx = 1:length(drive.powerSetPoints)
        if pdx==1
            tStart=tic;
            time=clock;
            timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
            filename=['singleDriveHomodyne_' config.name '_'  timestr];
            
        end
        
        if pdx > 1 && drive.powerSetPoints(pdx) == drive.powerSetPoints(pdx-1)
            1;
        else
            rfgen.power = drive.powerSetPoints(pdx);
        end
        
        drive.powerVec = config.powerSetPoints(pdx)*ones(numReads);
        cardparams.averages = config.averages;
        
        card.SetParams(cardparams);
        
        % find a background measurement
        rfgen.PowerOff();
        pause(0.05);
        [IDataBackground, QDataBackground] = card.ReadIandQ();
        IDataBackground = IDataBackground(1:int32(cardparams.samples));
        QDataBackground = QDataBackground(1:int32(cardparams.samples));
        
        rfgen.PowerOn();
        
        ampDataSingle = zeros(length(drive.powerVec),int32(cardparams.samples));
        IDataSingle = zeros(length(drive.powerVec),int32(cardparams.samples));
        QDataSingle = zeros(length(drive.powerVec),int32(cardparams.samples));
        IDataAvg = zeros(1,length(drive.powerVec));
        QDataAvg = zeros(1,length(drive.powerVec));
        ampDataAvg = zeros(1,length(drive.powerVec));
        ampDataPostAvg = zeros(1,length(drive.powerVec));
       
        
        for idx = 1:length(drive.powerVec) %loop over the reads
            tTrialStart  = tic;
            if pdx ==1 && idx ==1
                tStart=tic;
                time=clock;
            end
            rfgen.power = drive.powerVec(idx);
            pause(0.1);
            
            % get the read
            [IDataTemp, QDataTemp] = card.ReadIandQ();
            IDataTemp = IDataTemp(1:int32(cardparams.samples))-IDataBackground;
            QDataTemp = QDataTemp(1:int32(cardparams.samples))-QDataBackground;
            
            
            %do the averaging
            IDataAvg(idx) = mean(IDataTemp);
            QDataAvg(idx) = mean(QDataTemp);
            
            ampDataAvg(idx) = IDataAvg(idx)^2 + QDataAvg(idx)^2;
            ampDataPostAvg(idx) = mean(IDataTemp.^2 + QDataTemp.^2);
            
            
            
            minSamplesPerDivision = (targetTimeDuration/cardparams.sampleinterval)/numDivisions(1);
            for divdx = 1:numDivisions(1)
                ISection = IDataTemp((divdx-1)*minSamplesPerDivision:(divdx)*minSamplesPerDivision);
                QSection = QDataTemp((divdx-1)*minSamplesPerDivision:(divdx)*minSamplesPerDivision);

                Imean = mean(ISection);
                Qmean = mean(QSection);
                ampMean = Imean^2 + Qmean^2;

                ampDataAvgMat(pdx,(idx-1)*numDivisions(1)+divdx) = ampMean;
            end
            
%             % Now look at single traces with respect to averages
%             cardparams.averages = 1;
%             card.SetParams(cardparams);
%             pause(0.15);
%             [IDataTemp, QDataTemp] = card.ReadIandQ();
%             
%             IDataSingle(idx,:) = IDataTemp(1:int32(cardparams.samples))-IDataBackground;
%             QDataSingle(idx,:) = IDataTemp(1:int32(cardparams.samples))-QDataBackground;
%             
%             ampDataSingle(idx,:) = IDataSingle(idx,:).^2+QDataSingle(idx,:).^2;
            
            deltaT_trialEnd = toc(tTrialStart);
            if idx==1 && pdx == 1 && acq == 1
                disp(['single trial time = ' num2str(deltaT_trialEnd)])
                deltaT=toc(tStart);
%                 estimatedTime=deltaT*length(drive.powerVec)*length(drive.powerSetPoints)*mean(cardAcqLengths)/cardAcqLengths(1);
                temp = size(acquisitionPoints);
                numAcqs = temp (2);
                estimatedTime=deltaT*length(drive.powerVec)*length(drive.powerSetPoints)*numAcqs;
                disp(['Estimated Time is '...
                    num2str(estimatedTime/3600),' hrs, or '...
                    num2str(estimatedTime/60),' min']);
                disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                    round(estimatedTime),'second'))]);
            end
        end %end loop over the reads
        
       
        figure(22+acq);
        clf()
        subplot(2,1,1);
        if any(diff(drive.powerSetPoints)==0)
            yaxisTicks = 1:pdx;
        else
            yaxisTicks = drive.powerSetPoints(1:pdx);
        end
        imagesc(1:numReads,yaxisTicks,ampDataAvgMat(1:pdx,:));
        title([filename ', ampDataAvgMat']);
        xlabel('Trials');
        ylabel('Drive Set Points [dBm]');
        
        subplot(2,1,2);
%         imagesc(1:numReads,drive.powerSetPoints(1:pdx),ampDataPostAvgMat(1:pdx,:));
%         title('ampDataAvgPostAvg');
%         xlabel('Trials');
%         ylabel('Drive Set Points [dBm]');
        title('histogram at min binning')
        hist(ampDataAvgMat(pdx,:))
        xlabel('homodyne amplitude')
        ylabel('occurences')
        
        
        
    end %end loop over the power set points
    
    
    ampDataAvgStruct = {};
    ampDataAvgStruct.(['avgWind' num2str(avgingWindows(1)*10^6) 'us']) = ampDataAvgMat;
    %down sample the data.
    for avgdx = 2:length(avgingWindows)
       downSampleRate = avgingWindows(avgdx)/avgingWindows(1);
       
       oldSize = size(ampDataAvgMat);
       newSize = [oldSize(1) floor(oldSize(2)/downSampleRate)];
       newData = zeros(newSize);
       
       for sampdx = 1:newSize(2)
          newData(:,sampdx) = mean(ampDataAvgMat(:,(1+(sampdx-1)*downSampleRate): (sampdx)*downSampleRate  )   ,2);
       end
       ampDataAvgStruct.(['avgWind' num2str(avgingWindows(avgdx)*10^6) 'us']) = newData;
    end
    
    
    
    
    saveFolder = ['Z:\Mattias\Data\tunableDimer\singleDriveHomodyne_' runDate '\'];
    isFolder = exist(saveFolder);
    if isFolder == 0
        mkdir(saveFolder)
    end
    save([saveFolder filename '.mat'],...
        'CM','f0','fc','drive','ampDataAvgMat','config',...
        'cardparams', 'rfgen', 'logen', 'ampDataAvgStruct', 'avgingWindows', 'acquisitionPoints', ...
        'acq')

    title(filename)
    savefig([saveFolder filename '.fig']);

    currFilePath = mfilename('fullpath');
    savePath = [saveFolder filename 'AK' '.mat'];
    funclib.save_all(savePath, currFilePath);
    
end %end loop over all the acquisitions
