
funclib.clear_local_variables()

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
% CM = [1 0 0; 0 1 0; 120/(7*39) -120/(7*40) 1/0.45];  % Updated 8/12 to include qubit effects on coupler
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
triggerWaitTime = 20e-9;
samplingRate = 0.2e9;
scalingFactor = 254;
fprintf(tek.instrhandle, 'SOURCE1:FREQUENCY %f;', samplingRate);
taxis = 0:1/samplingRate:60e-6;
tstart = 20e-9;

% set up pi pulse
gatelist = {'X180'};
pulseCal = paramlib.pulseCal();
gateSeq = pulselib.gateSequence();
pulseCal.sigma = 150e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.X180Amplitude = 1.0;
gateSeq.append(pulselib.delay(30e-6));
gateSeq.append(pulseCal.X180);
[iWaveform, qWaveform] = gateSeq.uwWaveforms(taxis, tstart);
ch2 = scalingFactor*iWaveform;
clear iWaveform qWaveform

% set up measurement pulse
gateSeq = pulselib.gateSequence();
pulseCal.measDuration = 50e-6;
pulseCal.cavityAmplitude = 1.0;
gateSeq.append(pulselib.delay(5e-6));
gateSeq.append(pulseCal.measurement);
[iWaveform, qWaveform] = gateSeq.uwWaveforms(taxis, tstart);
ch3 = scalingFactor*iWaveform;
clear iWaveform qWaveform

% set up trigger
trigWaveform = ones(1,length(taxis)).*(taxis>(triggerWaitTime)).*(taxis<(triggerWaitTime+1e-6));
trig = trigWaveform;

%Download waveforms
fprintf(tek.instrhandle, 'wlis:wav:del all');
fprintf(tek.instrhandle,'awgc:stop');
fprintf(tek.instrhandle, 'awgc:rmod trig');

%load waveforms onto waveform list
DigWform1 = ADConvert(ch2, 'ch');
WformName1 = 'ch2';
DigWform1_Markers = ADConvert(trig,trig,'ch_marker');
TekTransferWform2(tek.instrhandle, WformName1, DigWform1, DigWform1_Markers, length(ch2));

%load waveforms onto waveform list
DigWform1 = ADConvert(ch3, 'ch');
WformName1 = 'ch3';
DigWform1_Markers = ADConvert(trig,trig,'ch_marker');
TekTransferWform2(tek.instrhandle, WformName1, DigWform1, DigWform1_Markers, length(ch3));

%load waveforms from the list onto the channels
fprintf(tek.instrhandle, 'sour2:wav "ch2" ');
% fprintf(tek.instrhandle, 'sour2:Dig:Voltage:OFFSET 0.0') %this does nothing, set manually
fprintf(tek.instrhandle, 'output2 on');

fprintf(tek.instrhandle, 'sour3:wav "ch3" ');
% fprintf(tek.instrhandle, 'sour3:Dig:Voltage:OFFSET 0.5') %this does nothing, set manually
fprintf(tek.instrhandle, 'output3 on');

fprintf(tek.instrhandle,'awgc:run');
%
% Start pulse generation. 
fprintf(tek.instrhandle,'awgc:run');

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
% targetTimeDuration = 50e-6;
targetTimeDuration = 70e-6;
samplerate = 1.6e9/32;

% plotMode = 'multi';
plotMode = 'single';

clear acquisitionPoints measurementPoint
tempdx = 0;


% fstart=[leftQubitMin rightQubitMin 0.0];
% fstop=[leftQubitMin rightQubitMin+0.025 0.0];fsteps=10;
% vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
% vtraj=fc.generateTrajectory(vstart,vstop,fsteps);

fstart=[leftQubitMin rightQubitMin 0.0];
fstop=[leftQubitMin rightQubitResonance 0.0];fsteps=10;
vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);

% qubitDrivePowerVec = [-100 linspace(-20,19,10)];

driveFreqVec = [5.905e9];
% qubitDrivePowerVec = [-100 10];
qubitDrivePowerVec = [10];

for fdx = 1:length(driveFreqVec)
    for ldx = 1:length(qubitDrivePowerVec)
        tempdx = tempdx+1;
        measurementPoint = {};
        measurementPoint.voltagePoint = vtraj(:,4);
        measurementPoint.qubitFreq = 4.24e9;
%         measurementPoint.qubitFreq = 5.9e9;
        measurementPoint.qubitDrivePower = qubitDrivePowerVec(ldx);
        measurementPoint.powerSetPoints = [linspace(0, 10, 5)];
%         measurementPoint.powerSetPoints = [8];
        measurementPoint.numReads = 5;
        measurementPoint.segments = 8;
        measurementPoint.probeFrequency = driveFreqVec(fdx);
        measurementPoint.averages = 6000/measurementPoint.segments;
        if qubitDrivePowerVec(ldx)<-20
            measurementPoint.name = ['pulseCalibration_maxJ_DDDOswitchingCompare_qubitDriveOff_driveAt' num2str(measurementPoint.probeFrequency/1e9)];
        else
            measurementPoint.name = ['pulseCalibration_maxJ_DDDOswitchingCompare_qubitDrivePower' num2str(qubitDrivePowerVec(ldx)) 'dBm_driveAt' num2str(measurementPoint.probeFrequency/1e9)];
        end
        acquisitionPoints(tempdx) = measurementPoint;
    end
    
%     for ldx = 2:length(qubitDrivePowerVec)
%         tempdx = tempdx+1;
%         measurementPoint = {};
%         measurementPoint.voltagePoint = vtraj(:,8);
%         measurementPoint.qubitFreq = 3.524e9;
%         measurementPoint.qubitDrivePower = qubitDrivePowerVec(ldx);
% %         measurementPoint.powerSetPoints = [linspace(3, 8, 5)];
%         measurementPoint.powerSetPoints = [6.75];
%         measurementPoint.numReads = 5;
%         measurementPoint.segments = 8;
%         measurementPoint.probeFrequency = driveFreqVec(fdx);
%         if qubitDrivePowerVec(ldx)<-20
%             measurementPoint.name = ['pulseCalibration_150nsSigma_maxJ_DDDOswitchingCompare_offResonance_qubitDriveOff_driveAt' num2str(measurementPoint.probeFrequency/1e9)];
%         else
%             measurementPoint.name = ['pulseCalibration_150nsSigma_maxJ_DDDOswitchingCompare_offResonance_qubitDrivePower' num2str(qubitDrivePowerVec(ldx)) 'dBm_driveAt' num2str(measurementPoint.probeFrequency/1e9)];
%         end
%         measurementPoint.averages = 6000/measurementPoint.segments;
%         acquisitionPoints(tempdx) = measurementPoint;
%     end
end

% qubitDrivePowerVec = [-100 linspace(-20,19,3)];
% 
% driveFreqVec = [5.9e9];
% % qubitDrivePowerVec = [-100];
% for fdx = 1:length(driveFreqVec)
%     for ldx = 1:length(qubitDrivePowerVec)
%         tempdx = tempdx+1;
%         measurementPoint = {};
%         measurementPoint.voltagePoint = vtraj(:,8);
%         measurementPoint.qubitFreq = 3.324e9;
%         measurementPoint.qubitDrivePower = qubitDrivePowerVec(ldx);
%         measurementPoint.powerSetPoints = [linspace(3, 8, 5)];
%         measurementPoint.numReads = 5;
%         measurementPoint.segments = 8;
%         measurementPoint.probeFrequency = driveFreqVec(fdx);
%         measurementPoint.averages = 6000/measurementPoint.segments;
%         if qubitDrivePowerVec(ldx)<-20
%             measurementPoint.name = ['maxJ_DDDOswitchingCompare_qubitDriveOff_driveAt' num2str(measurementPoint.probeFrequency/1e9)];
%         else
%             measurementPoint.name = ['maxJ_DDDOswitchingCompare_qubitDrivePower' num2str(qubitDrivePowerVec(ldx)) 'dBm_driveAt' num2str(measurementPoint.probeFrequency/1e9)];
%         end
%         acquisitionPoints(tempdx) = measurementPoint;
%     end
%     
% 
%     
%     for ldx = 2:length(qubitDrivePowerVec)
%         tempdx = tempdx+1;
%         measurementPoint = {};
%         measurementPoint.voltagePoint = vtraj(:,8);
%         measurementPoint.qubitFreq = 3.524e9;
%         measurementPoint.qubitDrivePower = qubitDrivePowerVec(ldx);
%         measurementPoint.powerSetPoints = [linspace(3, 8, 5)];
%         measurementPoint.numReads = 5;
%         measurementPoint.segments = 8;
%         measurementPoint.probeFrequency = driveFreqVec(fdx);
%         if qubitDrivePowerVec(ldx)<-20
%             measurementPoint.name = ['maxJ_DDDOswitchingCompare_offResonance_qubitDriveOff_driveAt' num2str(measurementPoint.probeFrequency/1e9)];
%         else
%             measurementPoint.name = ['maxJ_DDDOswitchingCompare_offResonance_qubitDrivePower' num2str(qubitDrivePowerVec(ldx)) 'dBm_driveAt' num2str(measurementPoint.probeFrequency/1e9)];
%         end
%         measurementPoint.averages = 6000/measurementPoint.segments;
%         acquisitionPoints(tempdx) = measurementPoint;
%     end
% end






%% Set up Trigger

% triggen.period = 10e-6;
triggen.offset=1;
triggen.vpp=2;
triggen.PowerOn();


%% Set up Generators

rfgen.ModOff();
logen.ModOff();

rfgen.PowerOn();

% logen.power = 12.5;
logen.power = 15.5; %split LO
logen.PowerOn();

rfgen.ModOn();
rfgen.pulse = 0;


cavitygen.freq = 5.908e9;
logen.freq = cavitygen.freq;

%% Set Up Card Parameters

% cardparams_fromDefault=paramlib.m9703a();   %default parameters
% card.SetParams_MS(cardparams_fromDefault); %magic function that seems to reset some errors even though it doesn't set card parameters well
% 
% % % % % % %store away and act on derrived settings
% % % % % % cardparams =cardparams_fromDefault;
% % % % % % sampleinterval = 1/cardparams_fromDefault.samplerate;
% % % % % % cardparams.sampleinterval = sampleinterval;
% % % % % % targetTimeDuration = cardparams_fromDefault.samples/cardparams_fromDefault.samplerate;
% % % % % % triggen.period = cardparams_fromDefault.trigPeriod;
% % % % % % cardparams.trigPeriod = triggen.period;

% cardparams = paramlib.acqiris();
cardparams = paramlib.m9703a();
% cardparams.fullscale = 0.5;
cardparams.fullscale = 1;
cardparams.offset = 0e-6;

% cardparams.trigSource = 'External1';
cardparams.trigSource = 'Channel1';

cardparams.samplerate = samplerate;
exponent = nextpow2(targetTimeDuration*cardparams.samplerate);
actualTimeDuration = (2^exponent)/cardparams.samplerate;
cardparams.samples = 2^exponent;
if cardparams.samples<2048
    disp('CARD NEEDS MORE SAMPLES, we think.')
    return
end
cardparams.averages = 4;
cardparams.segments = 5;
cardparams.delaytime = 0e-6;
cardparams.couplemode = 'DC';
corrparams.limCount=1;

triggen.period = actualTimeDuration+1e-6;
% cardparams.trigPeriod = triggen.period;

card.SetParams(cardparams);
% cardparams.trigPeriod = triggen.period; %this guy isn't handled right by the code right now. Putting it back.

% Time axis in us
timeaxis = (0:card.params.samples-1)/card.params.samplerate/1e-6;

%% loop over the different types of acqusitions

clear IData QData

temp = size(acquisitionPoints);
numAcquisitions = temp(2);

exponent = nextpow2(targetTimeDuration*cardparams.samplerate);
actualTimeDuration = (2^exponent)/cardparams.samplerate;
cardparams.samples = 2^exponent;
triggen.period = actualTimeDuration+1e-6;
% cardparams.trigPeriod = triggen.period;
card.SetParams(cardparams);
% cardparams.trigPeriod = triggen.period; %this guy isn't handled right by the code right now. Putting it back.

% avgingWindows = [2.5, 5, 10, 20, 50, 100]*1e-6;
avgingWindows = [1, 5, 10, 20]*1e-6; %%%%%!!!!!!!!!!!!!! must be integer divisions of target time duration, maybe not any more ?
% avgingWindows = [0.5, 1, 2, 5]*1e-6;
numDivisions = floor(targetTimeDuration./avgingWindows);

acquisitionChannels = [3,4,5,6];

% for acq = 5
for acq = 1:numAcquisitions
    config = acquisitionPoints(acq);
    %     numReads = config.numReads; %number of card acquisitions
    numCardReads = config.numReads;
    cardparams.segments = config.segments; %will be set right before taking background or measureing data
    
    drive.powerSetPoints = config.powerSetPoints;
    
    fc.currentVoltage = config.voltagePoint;
    
    %set the frequency of the rf gan for this measurement
    cavitygen.freq = config.probeFrequency;
    logen.freq = cavitygen.freq;
    
    avgOutput1 = zeros(1,length(drive.powerSetPoints));
    avgOutput2 = zeros(1,length(drive.powerSetPoints));
    for pdx = 1:length(drive.powerSetPoints)
        ampDataAvgMat = zeros(numCardReads*cardparams.segments,numDivisions(1)); %rezero data matrix
        ampDataAvgMat2 = zeros(numCardReads*cardparams.segments,numDivisions(1)); %rezero data matrix
        
        tStart=tic;
        time=clock;
        timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
        filename=[config.name '_' num2str(drive.powerSetPoints(pdx)) 'dBm_'  timestr];
        
        if pdx > 1 && drive.powerSetPoints(pdx) == drive.powerSetPoints(pdx-1)
            1;
        else
            cavitygen.power = drive.powerSetPoints(pdx);
        end
        
        cavitygen.power = drive.powerSetPoints(pdx);
        
%         ampDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
%         IDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
%         QDataSingle = zeros(numCardReads*cardparams.segments,int32(cardparams.samples));
%         IDataAvg = zeros(1,numCardReads*cardparams.segments);
%         QDataAvg = zeros(1,numCardReads*cardparams.segments);
%         ampDataAvg = zeros(1,numCardReads*cardparams.segments);
%         ampDataPostAvg = zeros(1,numCardReads*cardparams.segments);
%         
        
        for idx = 1:numCardReads %loop over the reads
            tTrialStart  = tic;
            if pdx ==1 && idx ==1
                tStart=tic;
                time=clock;
            end
            
            % find a background measurement
            cavitygen.PowerOff();
            pause(0.1);
%             cardparams.segments = config.averages; %fancy card doesn't do on board averages
            cardparams.segments = 600;
            cardparams.averages = 1;
            card.SetParams(cardparams);
%             cardparams.trigPeriod = triggen.period; %this guy isn't handled right by the code right now. Putting it back.
            
            pause(0.1);
            
            
            data = card.ReadChannels64_multiSegment(acquisitionChannels);
            dataSize = size(data);
            IDataBackground = data(1,:,:);
            IDataBackground = reshape(IDataBackground, dataSize(2), dataSize(3));
            QDataBackground = data(2,:,:);
            QDataBackground = reshape(QDataBackground, dataSize(2), dataSize(3));
            I2DataBackground = data(3,:,:);
            I2DataBackground = reshape(I2DataBackground, dataSize(2), dataSize(3));
            Q2DataBackground = data(4,:,:);
            Q2DataBackground = reshape(Q2DataBackground, dataSize(2), dataSize(3));
%             [IDataBackground, QDataBackground] = card.ReadIandQ();
%             IDataBackground = IDataBackground(:,1:int32(cardparams.samples));
%             QDataBackground = QDataBackground(:,1:int32(cardparams.samples));

            %get the average background
            IDataBackground = mean(IDataBackground(:));
            QDataBackground = mean(QDataBackground(:));
            I2DataBackground = mean(I2DataBackground(:));
            Q2DataBackground = mean(Q2DataBackground(:));

            
            %setup real acquisition
            rfgen.freq = config.qubitFreq;
            
            if config.qubitDrivePower<-50
                rfgen.PowerOff();
            else
                rfgen.power = config.qubitDrivePower;
                rfgen.PowerOn();
            end
            
            cavitygen.PowerOn();
            cardparams.averages = 1;
            cardparams.segments = config.segments; %back to a normal number of segments
            card.SetParams(cardparams);
%             cardparams.trigPeriod = triggen.period; %this guy isn't handled right by the code right now. Putting it back.
            

            % acquire new data set
%             [IDataTemp, QDataTemp] = card.ReadIandQ();
%             IDataTemp = IDataTemp(:,1:int32(cardparams.samples))-IDataBackground;
%             QDataTemp = QDataTemp(:,1:int32(cardparams.samples))-QDataBackground;
            data = card.ReadChannels64_multiSegment(acquisitionChannels);
            dataSize = size(data);
            IDataTemp = data(1,:,:);
            IDataTemp = reshape(IDataTemp, dataSize(2), dataSize(3));
            QDataTemp = data(2,:,:);
            QDataTemp = reshape(QDataTemp, dataSize(2), dataSize(3));
            I2DataTemp = data(3,:,:);
            I2DataTemp = reshape(I2DataTemp, dataSize(2), dataSize(3));
            Q2DataTemp = data(4,:,:);
            Q2DataTemp = reshape(Q2DataTemp, dataSize(2), dataSize(3));
            
            IDataTemp = IDataTemp(:,1:int32(cardparams.samples))-IDataBackground;
            QDataTemp = QDataTemp(:,1:int32(cardparams.samples))-QDataBackground;
            I2DataTemp = I2DataTemp(:,1:int32(cardparams.samples))-I2DataBackground;
            Q2DataTemp = Q2DataTemp(:,1:int32(cardparams.samples))-Q2DataBackground;
            
            
            
            minSamplesPerDivision = (targetTimeDuration*cardparams.samplerate)/numDivisions(1);
            
            % down-sample averaging
            for divdx = 1:numDivisions(1)
                ISection = IDataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                QSection = QDataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                
                Imean = mean(ISection,2);
                Qmean = mean(QSection,2);
                ampMean = Imean.^2 + Qmean.^2;
                
                ampDataAvgMat((idx-1)*cardparams.segments+1:(idx)*cardparams.segments,divdx) = ampMean;
                
                
                %second output
                I2Section = I2DataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                Q2Section = Q2DataTemp(:,(ceil((divdx-1)*minSamplesPerDivision)+1):ceil((divdx)*minSamplesPerDivision));
                
                I2mean = mean(I2Section,2);
                Q2mean = mean(Q2Section,2);
                ampMean2 = I2mean.^2 + Q2mean.^2;
                
                ampDataAvgMat2((idx-1)*cardparams.segments+1:(idx)*cardparams.segments,divdx) = ampMean2;
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
            
            numBins=80;
            %plot the data as it comes in
            g = figure(22+acq);
            clf()
            set(g, 'Position',  [41 103 1782 1002]);
            p = uipanel('Parent',g,'BorderType','none');
            p.Title = filename;
            p.TitlePosition = 'centertop';
            p.FontSize = 12;
            p.FontWeight = 'bold';
            
            subplot(1,4,1,'Parent',p);
            yaxis =1:idx*cardparams.segments;
            xaxis =1:numDivisions(1) *avgingWindows(1)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgMat(1:idx*cardparams.segments,:));
            title(['ampDataAvgMat']);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(2,4,2,'Parent',p);
            hist(reshape(ampDataAvgMat(1:idx*cardparams.segments,:),1,idx*cardparams.segments*numDivisions(1)),numBins)
            title('histogram of everything at min binning ')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
            subplot(2,4,6,'Parent',p);
            tempSection = ampDataAvgMat((1+(idx-1)*cardparams.segments):idx*cardparams.segments,:);
            hist(reshape(tempSection,1,cardparams.segments*numDivisions(1)),numBins)
            title('histogram of latest read at min binning')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
            
            %second channel
            subplot(1,4,3,'Parent',p);
            yaxis =1:idx*cardparams.segments;
            xaxis =1:numDivisions(1) *avgingWindows(1)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgMat2(1:idx*cardparams.segments,:));
            title(['ampDataAvgMat2']);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(2,4,4,'Parent',p);
            hist(reshape(ampDataAvgMat2(1:idx*cardparams.segments,:),1,idx*cardparams.segments*numDivisions(1)),numBins)
            title('histogram of everything at min binning2 ')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
            subplot(2,4,8,'Parent',p);
            tempSection = ampDataAvgMat2((1+(idx-1)*cardparams.segments):idx*cardparams.segments,:);
            hist(reshape(tempSection,1,cardparams.segments*numDivisions(1)),numBins)
            title('histogram of latest read at min binning2')
            xlabel('homodyne amplitude')
            ylabel('occurences')
            
        end %end loop over card reads
        
        
        
        
        %do all further down sampling and store result.
        ampDataAvgStruct = {};
        ampDataAvgStruct2 = {};
        
        ampDataAvgStruct.(['avgWind' num2str(avgingWindows(1)*10^9) 'ns']) = ampDataAvgMat;
        ampDataAvgStruct2.(['avgWind' num2str(avgingWindows(1)*10^9) 'ns']) = ampDataAvgMat2;
        dataMax = max(ampDataAvgMat(:));
        dataMax2 = max(ampDataAvgMat2(:));
        %down sample the data.
        for avgdx = 2:length(avgingWindows)
            downSampleRate = avgingWindows(avgdx)/avgingWindows(1);
            
            oldSize = size(ampDataAvgMat);
            newSize = [oldSize(1) floor(oldSize(2)/downSampleRate)];
            newData = zeros(newSize);
            newData2 = zeros(newSize);
            
            for sampdx = 1:newSize(2)
                newData(:,sampdx) = mean(ampDataAvgMat(:,(1+(sampdx-1)*downSampleRate): (sampdx)*downSampleRate  )   ,2);
                newData2(:,sampdx) = mean(ampDataAvgMat2(:,(1+(sampdx-1)*downSampleRate): (sampdx)*downSampleRate  )   ,2);
            end
            ampDataAvgStruct.(['avgWind' num2str(avgingWindows(avgdx)*10^6) 'us']) = newData;
            ampDataAvgStruct2.(['avgWind' num2str(avgingWindows(avgdx)*10^6) 'us']) = newData2;
            
            newDataMax = max(newData(:));
            newDataMax2 = max(newData2(:));
            if newDataMax>dataMax;
                dataMax = newDataMax;
            end
            if newDataMax2>dataMax2;
                dataMax2 = newDataMax2;
            end
        end
        
        %final plots
        fieldVals = fields(ampDataAvgStruct);
        if strcmp(plotMode, 'multi')
            f = figure(77+pdx);
        else
            f = figure(77);
        end
        set(f, 'Position', [68 184 1531 926]);
        clf()
        p = uipanel('Parent',f,'BorderType','none');
        p.Title = filename;
        p.TitlePosition = 'centertop';
        p.FontSize = 12;
        p.FontWeight = 'bold';
        for windx = 1:length(avgingWindows)
            fieldName = fieldVals{windx};
            subplot(4,length(avgingWindows), windx, 'Parent',p)
            yaxis =1:numCardReads*cardparams.segments;
            xaxis =1:numDivisions(windx) *avgingWindows(windx)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgStruct.(fieldName));
            title(['traces : ' fieldName]);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(4,length(avgingWindows), length(avgingWindows)+windx, 'Parent',p)
            hist(    reshape(ampDataAvgStruct.(fieldName),1,numCardReads*cardparams.segments*numDivisions(windx)),numBins)
            xlim([0,dataMax])
            title(['histogram : ' fieldName])
            xlabel('homodyne amplitude')
            ylabel('occurences')
        end
        %second channel
        for windx = 1:length(avgingWindows)
            fieldName = fieldVals{windx};
            subplot(4,length(avgingWindows), 2*length(avgingWindows)+windx, 'Parent',p)
            yaxis =1:numCardReads*cardparams.segments;
            xaxis =1:numDivisions(windx) *avgingWindows(windx)*10^6;
            imagesc(xaxis,yaxis,ampDataAvgStruct2.(fieldName));
            title(['traces2 : ' fieldName]);
            xlabel('time (us)');
            ylabel('trials');
            
            subplot(4,length(avgingWindows), 3*length(avgingWindows)+windx, 'Parent',p)
            hist(    reshape(ampDataAvgStruct2.(fieldName),1,numCardReads*cardparams.segments*numDivisions(windx)),numBins)
            xlim([0,dataMax2])
            title(['histogram2 : ' fieldName])
            xlabel('homodyne amplitude')
            ylabel('occurences')
        end
        
        
        
        %save data for each measurement configuration and each
        %power set point and acquisition setup
        %         saveFolder = ['Z:\Mattias\Data\tunableDimer\singleDriveHomodyne_' runDate '\'];
        %          saveFolder = ['Z:\Mattias\Data\tunableDimer\DualDriveCompareBistability_rightQubitDetuning_' runDate '\'];
        %          saveFolder = ['Z:\Mattias\Data\tunableDimer\DualDriveCompareBistability_LeftOutput_' runDate '\'];
        %          saveFolder = ['Z:\Mattias\Data\tunableDimer\singleDriveHomodyne_DualOutput_' runDate '\'];
        saveFolder = ['Z:\Mattias\Data\tunableDimer\dualDriveHomodyne_DualOutput_' runDate '\'];
        isFolder = exist(saveFolder);
        if isFolder == 0
            mkdir(saveFolder)
        end
        save([saveFolder filename '.mat'],...
            'CM','f0','fc','drive','ampDataAvgMat','config',...
            'cardparams', 'rfgen', 'logen', 'ampDataAvgStruct', 'avgingWindows', 'acquisitionPoints', ...
            'acq','numCardReads','vtraj','ampDataAvgMat2','ampDataAvgStruct2' )
        
        savefig(f, [saveFolder filename '.fig']);
        
        currFilePath = mfilename('fullpath');
        savePath = [saveFolder filename 'AK' '.mat'];
        %         funclib.save_all(savePath, currFilePath);
    end
        
%         h = figure(99);
%         set(f, 'Position', [68 184 1531 926]);
%         clf()
%         p = uipanel('Parent',h,'BorderType','none');
%         p.Title = filename;
%         p.TitlePosition = 'centertop';
%         p.FontSize = 12;
%         p.FontWeight = 'bold';
%         for windx = 1:length(avgingWindows)
%             fieldName = fieldVals{windx};
%             subplot(2,length(avgingWindows), windx, 'Parent',p)
%             yaxis =1:numCardReads*cardparams.segments;
%             xaxis =1:numDivisions(windx) *avgingWindows(windx)*10^6;
%             
% %             Mat1 = ampDataAvgStruct.(fieldName);
% %             Mat1 = Mat1 - min(Mat1(:));
% %             Mat1 = Mat1/max(Mat1(:));
% %             Mat2 = ampDataAvgStruct2.(fieldName);
% %             Mat2 = Mat2 - min(Mat2(:));
% %             Mat2 = Mat2/max(Mat2(:));
% %             plotMat = Mat1 + Mat2;
%             Mat1 = ampDataAvgStruct.(fieldName);
%             threshold1 = mean(Mat1(:));
%             Mat1 = Mat1 > threshold1;
%             Mat2 = ampDataAvgStruct2.(fieldName);
%             threshold2 = mean(Mat2(:));
%             Mat2 = Mat2 > threshold2;
%             plotMat = Mat1 + Mat2;
%             
%             imagesc(xaxis,yaxis,plotMat);
%             title(['correlator matrix : ' fieldName]);
%             xlabel('time (us)');
%             ylabel('trials');
%             
%             subplot(2,length(avgingWindows), length(avgingWindows)+windx, 'Parent',p)
%             hist(    reshape(plotMat,1,numCardReads*cardparams.segments*numDivisions(windx)),numBins)
%             xlim([0,2])
%             title(['corltn histogram : ' fieldName])
%             xlabel('contrast of amplitude')
%             ylabel('occurences')
%             
%         end
        
%         savefig(h, [saveFolder filename '_corr.fig']);
%              
%         avgOutput1(pdx) = mean(ampDataAvgMat(:));
%         avgOutput2(pdx) = mean(ampDataAvgMat2(:));
%         % plot a figure of the avg output homodyne
%         f = figure(99);
%         set(f, 'Position', [68 184 1531 926]);
%         clf()
%         subplot(2,1,1);
%         plot(drive.powerSetPoints(1:pdx),avgOutput1(1:pdx));
%         xlabel('Drive Power [dBm]');
%         ylabel('Avg Homodyne Amplitude');
%         title([config.name '_avgAmp_' timestr '.fig, Left Output'])
%         
%         subplot(2,1,2);
%         plot(drive.powerSetPoints(1:pdx),avgOutput2(1:pdx));
%         xlabel('Drive Power [dBm]');
%         ylabel('Avg Homodyne Amplitude');
%         title('Right Output');
%         
        
        
        
        
        
%     end %end loop over power set points
%     
%     savefig(f, [saveFolder config.name '_avgAmp_' timestr '.fig']);
    
end %end loop over all the acquisitions

% fc.currentVoltage=[0 0 0];