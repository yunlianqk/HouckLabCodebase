
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
% fstart=[leftQubitMin (rightQubitResonance-0.15) 0];
% fstop=[leftQubitMin (rightQubitResonance+0.15) 0];fsteps=20;

% fstart=[(leftQubitResonance) rightQubitMin-0.15 couplerMinJ];
% fstop=[(leftQubitResonance) rightQubitMin+0.15 couplerMinJ];fsteps=50;

fstart=[(leftQubitResonance) rightQubitMin couplerMinJ];
fstop=[(leftQubitResonance) rightQubitMin couplerMinJ];fsteps=50;

% fstart=[(leftQubitResonance-0.15) rightQubitMin 0.22];
% fstop=[(leftQubitResonance+0.2) rightQubitMin 0.22];fsteps=25;

vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
voltageCutoff = 3.5;

if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);

vtraj(:,23)
% fc.currentVoltage = vtraj(:,23); 
% fc.currentVoltage = vtraj(:,19); 

%%   set up all the different measurements
targetTimeDuration = 100e-6;
sampleinterval = 64e-9;
% targetTimeDuration = 50e-6;
% sampleinterval = 16e-9;

clear acquisitionPoints measurementPoint

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

measurementPoint = {};
measurementPoint.name = 'maxJ_dualDriveSplit_leftResonance';
measurementPoint.voltagePoint = [-1.2403 -0.6374 0.1603];
measurementPoint.powerSetPoints =linspace(-18.0, -15.0, 20);
measurementPoint.numReads = 500;
measurementPoint.segments = 20;
measurementPoint.probeFrequency = 5.909e9;
measurementPoint.averages = 6000/measurementPoint.segments;
acquisitionPoints(1) = measurementPoint;

measurementPoint = {};
measurementPoint.name = 'minJ_dualDriveSplit_leftResonance';
measurementPoint.voltagePoint = [-1.2364 -0.5894 0.3657];
measurementPoint.powerSetPoints = linspace(-27, -10,20);
measurementPoint.numReads = 500;
measurementPoint.segments = 20;
measurementPoint.probeFrequency = 5.872e9;
measurementPoint.averages = 6000/measurementPoint.segments;
acquisitionPoints(2) = measurementPoint;

measurementPoint = {};
measurementPoint.name = 'maxJ_dualDriveSplit_doubleResonance';
measurementPoint.voltagePoint = [-1.2465 -0.6374 0.1603];
measurementPoint.powerSetPoints =linspace(-19.0, -15,20);
measurementPoint.numReads = 500;
measurementPoint.segments = 20;
measurementPoint.probeFrequency = 5.909e9;
measurementPoint.averages = 6000/measurementPoint.segments;
acquisitionPoints(3) = measurementPoint;


%%%max J % right qubit and left qubit in resonance
measurementPoint = {};
measurementPoint.name = 'maxJ_dualDriveSplit_rightResonance';
% measurementPoint.voltagePoint = [-1.2465 -0.6374 0.1603];
measurementPoint.voltagePoint = [1.4290, -0.2435, -0.2671];
% measurementPoint.powerSetPoints = linspace(-45,-30,15);
% measurementPoint.powerSetPoints =linspace(-34.5, -29.5,5);
measurementPoint.powerSetPoints =linspace(-19.0, -15,20);
measurementPoint.numReads = 500;
measurementPoint.segments = 20;
measurementPoint.probeFrequency = 5.909e9;
measurementPoint.averages = 6000/measurementPoint.segments;
acquisitionPoints(4) = measurementPoint;

%%%small J
measurementPoint = {};
measurementPoint.name = 'minJ_dualDriveSplit_doubleResonance';
measurementPoint.voltagePoint = [-1.2404, -0.6210, 0.3603];
% measurementPoint.powerSetPoints = linspace(-29,-25,5);
% measurementPoint.powerSetPoints = linspace(-29,-24,10);
% measurementPoint.powerSetPoints = -27*ones(1,16);
measurementPoint.powerSetPoints = linspace(-25, -15,20);
measurementPoint.numReads = 500;
measurementPoint.segments = 20;
measurementPoint.probeFrequency = 5.872e9;
measurementPoint.averages = 6000/measurementPoint.segments; %number of averages for background measurement
acquisitionPoints(5) = measurementPoint;

%%%small J
measurementPoint = {};
measurementPoint.name = 'minJ_dualDriveSplit_rightResonance';
measurementPoint.voltagePoint = [1.4351, -0.2272, -0.0671];
% measurementPoint.powerSetPoints = linspace(-29,-25,5);
% measurementPoint.powerSetPoints = linspace(-29,-24,10);
% measurementPoint.powerSetPoints = -27*ones(1,16);
measurementPoint.powerSetPoints = linspace(-25, -15,20);
measurementPoint.numReads = 500;
measurementPoint.segments = 20;
measurementPoint.probeFrequency = 5.872e9;
measurementPoint.averages = 6000/measurementPoint.segments; %number of averages for background measurement
acquisitionPoints(6) = measurementPoint;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% %%%max J
% measurementPoint = {};
% measurementPoint.name = 'maxJ_2';
% measurementPoint.voltagePoint = [-1.5198 -0.5908 0.2207];
% % measurementPoint.powerSetPoints = linspace(-45,-30,15);
% % measurementPoint.powerSetPoints =linspace(-34.5, -29.5,5);
% measurementPoint.powerSetPoints =linspace(-30, -24,5);
% measurementPoint.numReads = 5;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.844e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;

% %%%%
% largeJ
% measurementPoint = {};
% measurementPoint.name = 'largeJ_2';
% % measurementPoint.voltagePoint = [-1.0724 -0.5875 0.2362]; % traj 10
% measurementPoint.voltagePoint = [-1.4043 -0.5903 0.2981]; % traj 8
% % measurementPoint.powerSetPoints = [-41, -40, -39, -38, -37, -36, -35]; %collumns
% % measurementPoint.powerSetPoints = [-38,-38, -37, -37, -36, -36];
% measurementPoint.powerSetPoints = linspace(-40,-30,30);
% measurementPoint.numReads = 5;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.841e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;


% %%%%minJ
% measurementPoint = {};
% measurementPoint.name = 'minJ';
% % measurementPoint.voltagePoint = [-1.0724 -0.5875 0.2362]; % traj 10
% measurementPoint.voltagePoint = [-1.6809 -0.5926 0.3497]; % traj 8
% % measurementPoint.powerSetPoints = [-41, -40, -39, -38, -37, -36, -35]; %collumns
% % measurementPoint.powerSetPoints = [-38,-38, -37, -37, -36, -36];
% measurementPoint.powerSetPoints = linspace(-20,-5,10);
% measurementPoint.numReads = 5;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.825e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;

% %%%%largeJ
% measurementPoint = {};
% measurementPoint.name = 'largeJ_@';
% % measurementPoint.voltagePoint = [-1.0724 -0.5875 0.2362]; % traj 10
% measurementPoint.voltagePoint = [-1.4043 -0.5903 0.2981]; % traj 8
% % measurementPoint.powerSetPoints = [-41, -40, -39, -38, -37, -36, -35]; %collumns
% % measurementPoint.powerSetPoints = [-38,-38, -37, -37, -36, -36];
% measurementPoint.powerSetPoints = linspace(-40,-30,30);
% measurementPoint.numReads = 5;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.841e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;


% %%%max J % right qubit and left qubit in resonance
% measurementPoint = {};
% measurementPoint.name = 'maxJ_splitter_rightDrive';
% measurementPoint.voltagePoint = [-1.2465 -0.6374 0.1603];
% % measurementPoint.voltagePoint = [1.4290, -0.2435, -0.2671];
% % measurementPoint.powerSetPoints = linspace(-45,-30,15);
% % measurementPoint.powerSetPoints =linspace(-34.5, -29.5,5);
% measurementPoint.powerSetPoints =linspace(-18.0, -15,5);
% measurementPoint.numReads = 20;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;



% %%%max J  % nice point for right drive, right output bistability
% measurementPoint = {};
% measurementPoint.name = 'maxJ';
% measurementPoint.voltagePoint = [1.4290, -0.2435, -0.2671];
% % measurementPoint.powerSetPoints = linspace(-45,-30,15);
% % measurementPoint.powerSetPoints =linspace(-34.5, -29.5,5);
% measurementPoint.powerSetPoints =linspace(-23, -23,1);
% measurementPoint.numReads = 20;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;



% %%%max J
% measurementPoint = {};
% measurementPoint.name = 'maxJ';
% measurementPoint.voltagePoint = [1.4290, -0.2435, -0.2671];
% % measurementPoint.powerSetPoints = linspace(-45,-30,15);
% % measurementPoint.powerSetPoints =linspace(-34.5, -29.5,5);
% measurementPoint.powerSetPoints =linspace(-27, -21,20);
% measurementPoint.numReads = 250;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(1) = measurementPoint;

% %%%%largeJ
% measurementPoint = {};
% measurementPoint.name = 'largeJ';
% measurementPoint.voltagePoint = [1.4341, -0.2189, -0.1643];
% % measurementPoint.powerSetPoints = [-41, -40, -39, -38, -37, -36, -35]; %collumns
% % measurementPoint.powerSetPoints = [-38,-38, -37, -37, -36, -36];
% measurementPoint.powerSetPoints = linspace(-38,-35,20);
% measurementPoint.numReads = 250;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.908e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(2) = measurementPoint;
% 
% %%%small J
% measurementPoint = {};
% measurementPoint.name = 'minJ';
% measurementPoint.voltagePoint = [1.4351, -0.2272, -0.0671];
% % measurementPoint.powerSetPoints = linspace(-29,-25,5);
% % measurementPoint.powerSetPoints = linspace(-29,-24,10);
% % measurementPoint.powerSetPoints = -27*ones(1,16);
% measurementPoint.powerSetPoints = linspace(-28, -26,20);
% measurementPoint.numReads = 250;
% measurementPoint.segments = 20;
% measurementPoint.probeFrequency = 5.872e9;
% measurementPoint.averages = 6000/measurementPoint.segments; %number of averages for background measurement
% acquisitionPoints(3) = measurementPoint;



% %%%max J2
% measurementPoint = {};
% measurementPoint.name = 'maxJ2';
% measurementPoint.voltagePoint = [1.4290, -0.2435, -0.2671];
% % measurementPoint.powerSetPoints = linspace(-45,-30,15);
% measurementPoint.powerSetPoints = -32*ones(1,16);
% measurementPoint.numReads = 200;
% measurementPoint.segments = 10;
% measurementPoint.probeFrequency = 5.909e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(2) = measurementPoint;
% %%%%largeJ2
% measurementPoint = {};
% measurementPoint.name = 'largeJ2';
% measurementPoint.voltagePoint = [1.4341, -0.2189, -0.1643];
% % measurementPoint.powerSetPoints = [-41, -40, -39, -38, -37, -36, -35]; %collumns
% % measurementPoint.powerSetPoints = [-38,-38, -37, -37, -36, -36];
% measurementPoint.powerSetPoints = -38*ones(1,16);
% measurementPoint.numReads = 200;
% measurementPoint.segments = 10;
% measurementPoint.probeFrequency = 5.908e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
% acquisitionPoints(4) = measurementPoint;
% %%%small J2
% measurementPoint = {};
% measurementPoint.name = 'minJ2';
% measurementPoint.voltagePoint = [1.4351, -0.2272, -0.0671];
% % measurementPoint.powerSetPoints = linspace(-29,-25,5);
% % measurementPoint.powerSetPoints = linspace(-29,-24,10);
% measurementPoint.powerSetPoints = -26*ones(1,16);
% measurementPoint.numReads = 200;
% measurementPoint.segments = 10;
% measurementPoint.probeFrequency = 5.872e9;
% measurementPoint.averages = 6000/measurementPoint.segments;
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

% triggen.period = 10e-6;
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
if cardparams.samples<2048
    disp('CARD NEEDS MORE SAMPLES, we think.')
    return
end
cardparams.averages = 4;
cardparams.segments = 5;
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

clear IData QData

temp = size(acquisitionPoints);
numAcquisitions = temp(2);

exponent = nextpow2(targetTimeDuration/cardparams.sampleinterval);
actualTimeDuration = (2^exponent)*cardparams.sampleinterval;
cardparams.samples = 2^exponent;
triggen.period = actualTimeDuration+1e-6;
cardparams.trigPeriod = triggen.period;
card.SetParams(cardparams);

% avgingWindows = [2.5, 5, 10, 20, 50, 100]*1e-6;
% avgingWindows = [2, 5, 10, 20]*1e-6; %%%%%!!!!!!!!!!!!!! must be integer divisions of target time duration
avgingWindows = [1, 2, 5, 10, 20]*1e-6;
numDivisions = floor(targetTimeDuration./avgingWindows);

% for acq = 1
for acq = 1:numAcquisitions
    config = acquisitionPoints(acq);
    %     numReads = config.numReads; %number of card acquisitions
    numCardReads = config.numReads;
    cardparams.segments = config.segments; %will be set right before taking background or measureing data
    
    drive.powerSetPoints = config.powerSetPoints;
    
    fc.currentVoltage = config.voltagePoint;
    
    %set the frequency of the rf gan for this measurement
    rfgen.freq = config.probeFrequency;
    logen.freq = rfgen.freq;
    
    for pdx = 1:length(drive.powerSetPoints)
        ampDataAvgMat = zeros(numCardReads*cardparams.segments,numDivisions(1)); %rezero data matrix
        
        tStart=tic;
        time=clock;
        timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
        filename=['dualDriveHomodyne_' config.name '_' num2str(drive.powerSetPoints(pdx)) 'dBm_'  timestr];
        
        if pdx > 1 && drive.powerSetPoints(pdx) == drive.powerSetPoints(pdx-1)
            1;
        else
            rfgen.power = drive.powerSetPoints(pdx);
        end
        
        rfgen.power = drive.powerSetPoints(pdx);
        
        ampDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
        IDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
        QDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
        IDataAvg = zeros(1,numCardReads*cardparams.segments);
        QDataAvg = zeros(1,numCardReads*cardparams.segments);
        ampDataAvg = zeros(1,numCardReads*cardparams.segments);
        ampDataPostAvg = zeros(1,numCardReads*cardparams.segments);
        
        
        for idx = 1:numCardReads %loop over the reads
            tTrialStart  = tic;
            if pdx ==1 && idx ==1
                tStart=tic;
                time=clock;
            end
            
            % find a background measurement
            rfgen.PowerOff();
            pause(0.1);
            cardparams.averages = config.averages;
            card.SetParams(cardparams);
            pause(0.1);
            [IDataBackground, QDataBackground] = card.ReadIandQ();
            IDataBackground = IDataBackground(:,1:int32(cardparams.samples));
            QDataBackground = QDataBackground(:,1:int32(cardparams.samples));
            rfgen.PowerOn();
            cardparams.averages = 1;
            card.SetParams(cardparams);
            
            %get the average background
            IDataBackground = mean(IDataBackground(:));
            QDataBackground = mean(QDataBackground(:));

            % acquire new data set
            [IDataTemp, QDataTemp] = card.ReadIandQ();
            IDataTemp = IDataTemp(:,1:int32(cardparams.samples))-IDataBackground;
            QDataTemp = QDataTemp(:,1:int32(cardparams.samples))-QDataBackground;
            
            minSamplesPerDivision = (targetTimeDuration/cardparams.sampleinterval)/numDivisions(1);
            
            % down-sample averaging
            for divdx = 1:numDivisions(1)
                ISection = IDataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                QSection = QDataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                
                Imean = mean(ISection,2);
                Qmean = mean(QSection,2);
                ampMean = Imean.^2 + Qmean.^2;
                
                ampDataAvgMat((idx-1)*cardparams.segments+1:(idx)*cardparams.segments,divdx) = ampMean;
            end
            
            deltaT_trialEnd = toc(tTrialStart);
            if idx==1 && pdx == 1 && acq == 1
                disp(['single trial time = ' num2str(deltaT_trialEnd)])
                deltaT=toc(tStart);
                %                 estimatedTime=deltaT*length(drive.powerVec)*length(drive.powerSetPoints)*mean(cardAcqLengths)/cardAcqLengths(1);
                temp = size(acquisitionPoints);
                numAcqs = temp (2);
                estimatedTime=deltaT*numCardReads*length(drive.powerSetPoints)*numAcqs;
                disp(['Estimated Time is '...
                    num2str(estimatedTime/3600),' hrs, or '...
                    num2str(estimatedTime/60),' min']);
                disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                    round(estimatedTime),'second'))]);
            end
            
            
            %plot the data as it comes in
            g = figure(22+acq);
            clf()
            set(g, 'Position',  [120 321 939 678]);
            subplot(1,2,1);
            yaxis =1:idx*cardparams.segments;
            xaxis =1:numDivisions(1) *avgingWindows(1)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgMat(1:idx*cardparams.segments,:));
            title([filename ', ampDataAvgMat']);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(2,2,2);
            hist(reshape(ampDataAvgMat(1:idx*cardparams.segments,:),1,idx*cardparams.segments*numDivisions(1))       )
            title('histogram of everything at min binning ')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
            subplot(2,2,4);
            tempSection = ampDataAvgMat((1+(idx-1)*cardparams.segments):idx*cardparams.segments,:);
            hist(reshape(tempSection,1,cardparams.segments*numDivisions(1))       )
            title('histogram of latest read at min binning')
            xlabel('homodyne amplitude')
            ylabel('occurences')
        end %end loop over card reads
        
        
        
        
        %do all further down sampling and store result.
        ampDataAvgStruct = {};

        ampDataAvgStruct.(['avgWind' num2str(avgingWindows(1)*10^6) 'us']) = ampDataAvgMat;
        dataMax = max(ampDataAvgMat(:));
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
            
            newDataMax = max(newData(:));
            if newDataMax>dataMax;
                dataMax = newDataMax;
            end
        end

        %final plots
        fieldVals = fields(ampDataAvgStruct);
%         f = figure(77+pdx);
        f = figure(77);
        set(f, 'Position', [68 184 1531 926]);
        clf()
        p = uipanel('Parent',f,'BorderType','none');
        p.Title = filename;
        p.TitlePosition = 'centertop';
        p.FontSize = 12;
        p.FontWeight = 'bold';
        for windx = 1:length(avgingWindows)
            fieldName = fieldVals{windx};
            subplot(2,length(avgingWindows), windx, 'Parent',p)
            yaxis =1:numCardReads*cardparams.segments;
            xaxis =1:numDivisions(windx) *avgingWindows(windx)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgStruct.(fieldName));
            title(['traces : ' fieldName]);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(2,length(avgingWindows), length(avgingWindows)+windx, 'Parent',p)
            hist(    reshape(ampDataAvgStruct.(fieldName),1,numCardReads*cardparams.segments*numDivisions(windx))       )
            xlim([0,dataMax])
            title(['histogram : ' fieldName])
            xlabel('homodyne amplitude')
            ylabel('occurences')
        end
        
        
        
        %save data for each measurement configuration and each
        %power set point and acquisition setup
%         saveFolder = ['Z:\Mattias\Data\tunableDimer\singleDriveHomodyne_' runDate '\'];
         saveFolder = ['Z:\Mattias\Data\tunableDimer\DualDriveCompareBistability' runDate '\'];
        isFolder = exist(saveFolder);
        if isFolder == 0
            mkdir(saveFolder)
        end
        save([saveFolder filename '.mat'],...
            'CM','f0','fc','drive','ampDataAvgMat','config',...
            'cardparams', 'rfgen', 'logen', 'ampDataAvgStruct', 'avgingWindows', 'acquisitionPoints', ...
            'acq','numCardReads')
        
        savefig(f, [saveFolder filename '.fig']);
        
        currFilePath = mfilename('fullpath');
        savePath = [saveFolder filename 'AK' '.mat'];
        funclib.save_all(savePath, currFilePath);
        
    end %end loop over power set points
end %end loop over all the acquisitions
