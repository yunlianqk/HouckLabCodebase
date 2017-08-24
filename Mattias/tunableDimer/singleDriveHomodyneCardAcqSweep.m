
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
fstart=[leftQubitMin (rightQubitResonance-0.15) couplerMinJ];
fstop=[leftQubitMin (rightQubitResonance+0.15) couplerMinJ];fsteps=50;

vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
voltageCutoff = 3.5;

if (any(abs(vstart)>voltageCutoff) | any(abs(vstop)>voltageCutoff))
    disp('VOLTAGE IN TRAJECTORY IS TOO HIGH')
    return
end
vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
ftraj=fc.calculateFluxTrajectory(vtraj);

fc.currentVoltage = vtraj(:,23); 
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
% specgen.ModOff();

rfgen.PowerOn();
% rfgen.PowerOff();

% specgen.PowerOn();
% specgen.PowerOff();

logen.power = 12.5;
logen.PowerOn();

corrparams.Int_Freq = 0e6;
% corrparams.LPF = 10e3;
% corrparams.LPF = 1e6;

rfgen.freq = 5.872e9;
% rfgen.freq = 5.917e9;
% specgen.freq = 5.899e9;

logen.freq = rfgen.freq + corrparams.Int_Freq;

%% Set Up Card Parameters

cardparams = paramlib.acqiris();
cardparams.fullscale = 0.5;
cardparams.offset = 0e-6;

timeDuration = 5e-6;
cardparams.sampleinterval = 1e-9;
cardparams.samples = timeDuration/cardparams.sampleinterval;
cardparams.averages = 400000;
cardparams.segments = 1;
cardparams.delaytime = 1e-6;
cardparams.couplemode = 'DC';
cardparams.trigPeriod = triggen.period;

corrparams.limCount=1;

card.SetParams(cardparams);

% Time axis in us
timeaxis = (0:card.params.samples-1)*card.params.sampleinterval/1e-6;

%% Acquire test data

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

%%
driveEpsilon = 0.0001;

numTrials = 1000;
drive.powerSetPoints = linspace(-30,-24,40);
cardAcqLengths = [1e-6 6e-6 10e-6];

for acq = 1:length(cardAcqLengths)
    triggen.period =cardAcqLengths(acq)+4e-6;
    timeDuration = cardAcqLengths(acq);
    cardparams.trigPeriod = triggen.period;
    cardparams.samples = timeDuration/cardparams.sampleinterval;
    card.SetParams(cardparams);
    
    ampDataAvgMat = zeros(length(drive.powerSetPoints),numTrials);
    ampDataPostAvgMat = zeros(length(drive.powerSetPoints),numTrials);
    
    for pdx = 1:length(drive.powerSetPoints)
        if pdx==1
            tStart=tic;
            time=clock;
            timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
            filename=['singleDriveHomodyne_cardAcqLength' num2str(cardAcqLengths(acq)/1e-6) 'us_'  timestr];
            
        end
        
        drive.powerVec = linspace(drive.powerSetPoints(pdx),drive.powerSetPoints(pdx)+driveEpsilon,numTrials);
        
        cardparams.averages = 600000;
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
       
        
        for idx = 1:length(drive.powerVec)
            if pdx ==1 && idx ==1
                tStart=tic;
                time=clock;
            end
            rfgen.power = drive.powerVec(idx);
            pause(0.1);
            
            % find time average and trace average I and Q
            [IDataTemp, QDataTemp] = card.ReadIandQ();
            IDataTemp = IDataTemp(1:int32(cardparams.samples))-IDataBackground;
            QDataTemp = QDataTemp(1:int32(cardparams.samples))-QDataBackground;
            
            IDataAvg(idx) = mean(IDataTemp);
            QDataAvg(idx) = mean(QDataTemp);
            
            ampDataAvg(idx) = IDataAvg(idx)^2 + QDataAvg(idx)^2;
            ampDataPostAvg(idx) = mean(IDataTemp.^2 + QDataTemp.^2);
            
            % Now look at single traces with respect to averages
            cardparams.averages = 1;
            card.SetParams(cardparams);
            pause(0.15);
            [IDataTemp, QDataTemp] = card.ReadIandQ();
            
            IDataSingle(idx,:) = IDataTemp(1:int32(cardparams.samples))-IDataBackground;
            QDataSingle(idx,:) = IDataTemp(1:int32(cardparams.samples))-QDataBackground;
            
            ampDataSingle(idx,:) = IDataSingle(idx,:).^2+QDataSingle(idx,:).^2;
            
            %     % Plot data
            %     figure(1);
            %     subplot(3,2,1);
            %     imagesc(timeaxis, drive.powerVec(1:idx), IDataSingle(1:idx,:));
            %     title('IData');
            %     ylabel('Drive Power [dBm]');
            %     colorbar();
            %
            %     subplot(3,2,2);
            %     plot(drive.powerVec(1:idx), IDataAvg(1:idx));
            %     title('IDataAvg');
            %     xlabel('Drive Power [dBm]');
            %
            %     subplot(3,2,3);
            %     imagesc(timeaxis, drive.powerVec(1:idx), QDataSingle(1:idx,:));
            %     ylabel('Drive Power [dBm]');
            %     xlabel('Time (\mus)');
            %     colorbar();
            %
            %     subplot(3,2,4);
            %     plot(drive.powerVec(1:idx), QDataAvg(1:idx));
            %     title('QDataAvg');
            %     xlabel('Drive Power [dBm]');
            %
            %     subplot(3,2,5);
            %     imagesc(timeaxis, drive.powerVec(1:idx), ampDataSingle(1:idx,:));
            %     title('Amplitude');
            %     ylabel('Drive Power [dBm]');
            %     xlabel('Time (\mus)');
            %     colorbar();
            %
            %     subplot(3,2,6);
            %     plot(drive.powerVec(1:idx), ampDataAvg(1:idx));
            %     title('ampDataAvg');
            %     xlabel('Drive Power [dBm]');
            %
            if idx==1 && pdx == 1 && acq == 1
                deltaT=toc(tStart);
                estimatedTime=deltaT*length(drive.powerVec)*length(drive.powerSetPoints)*mean(cardAcqLengths)/cardAcqLengths(1);
                disp(['Estimated Time is '...
                    num2str(estimatedTime/3600),' hrs, or '...
                    num2str(estimatedTime/60),' min']);
                disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                    round(estimatedTime),'second'))]);
            end
        end
        
        ampDataPostAvgMat(pdx,:) = ampDataPostAvg;
        ampDataAvgMat(pdx,:) = ampDataAvg;
        
       
        figure(22+acq);
        subplot(2,1,1);
        imagesc(1:numTrials,drive.powerSetPoints(1:pdx),ampDataAvgMat(1:pdx,:));
        title([filename ', ampDataAvgMat']);
        xlabel('Trials');
        ylabel('Drive Set Points [dBm]');
        
        subplot(2,1,2);
        imagesc(1:numTrials,drive.powerSetPoints(1:pdx),ampDataPostAvgMat(1:pdx,:));
        title('ampDataAvgPostAvg');
        xlabel('Trials');
        ylabel('Drive Set Points [dBm]');
        
%         figure(33)
%         subplot(1,2,1)
%         hist(reshape(ampDataSingle,[],1),100)
%         subplot(1,2,2)
%         hist(ampDataAvg,30)
%         
    end
    
        saveFolder = ['Z:\Mattias\Data\tunableDimer\singleDriveHomodyne_' runDate '\'];
        isFolder = exist(saveFolder);
        if isFolder == 0
            mkdir(saveFolder)
        end
        save([saveFolder filename '.mat'],...
            'CM','f0','fc','drive','ampDataPostAvgMat','ampDataAvgMat','driveEpsilon','numTrials',...
            'cardparams','cardAcqLengths')

        title(filename)
        savefig([saveFolder filename '.fig']);

        currFilePath = mfilename('fullpath');
        savePath = [saveFolder filename 'AK' '.mat'];
        funclib.save_all(savePath, currFilePath);
    
end

%%

% 
% 
% % drive.powerVec = linspace(-40,5,20);
% drive.powerVec = linspace(-55,-10,30);
% % drive.freqVec = linspace(5.818e9,5.89e9,5);
% drive.freqVec = linspace(5.8e9,5.95e9,25);
% 
% warning('off','all');
% 
% clear rfparams moments photonCurrentMat phasePhotonCurrentMat...
%     a1a2Mat phaseMat ampMat ...
%     a2daga1Mat a1daga2Mat a1daga1Mat ...
%     a2daga2Mat a1Mat a2Mat
% 
% photonCurrentMat=zeros(length(drive.powerVec),length(drive.freqVec));
% photonCurrentMatNormalized=zeros(length(drive.powerVec),length(drive.freqVec));
% phaseMat=zeros(length(drive.powerVec),length(drive.freqVec));
% ampMat=zeros(length(drive.powerVec),length(drive.freqVec));
% phasePhotonCurrentMat=zeros(1,length(drive.powerVec),length(drive.freqVec));
% a2daga1Mat=zeros(length(drive.powerVec),length(drive.freqVec));
% a1daga2Mat=zeros(length(drive.powerVec),length(drive.freqVec));
% h2h1dagMat=zeros(length(drive.powerVec),length(drive.freqVec));
% h1h2dagMat=zeros(length(drive.powerVec),length(drive.freqVec));
% expOMat=zeros(length(drive.powerVec),length(drive.freqVec));
% expOSquaredMat=zeros(length(drive.powerVec),length(drive.freqVec));
% 
% a1daga1Mat=zeros(length(drive.powerVec),length(drive.freqVec));
% a2daga2Mat=zeros(length(drive.powerVec),length(drive.freqVec));
% a1Mat=zeros(length(drive.powerVec),length(drive.freqVec));
% a2Mat=zeros(length(drive.powerVec),length(drive.freqVec));
% 
% tStart = tic;
% time = clock;
% fileIdentifier='2channelDigitalHomodyne';
% 
% filename=['pC_leftInput_' num2str(time(1)) num2str(time(2)) num2str(time(3))...
%     num2str(time(4)) num2str(time(5))];
% 
% for idx = 1:length(drive.freqVec)
% 
% clear photonCurrentLine a2daga1Line ...
%     a1daga2Line a1daga1Line ...
%     a2daga2Line phasePhotonCurrentLine ...
%     phaseLine ampLine a1Line a2Line
% 
% rfgen.freq = drive.freqVec(idx);
% % specgen.freq = drive.freqVec(idx);
% logen.freq = rfgen.freq + corrparams.Int_Freq;
% 
% photonCurrentLine=zeros(length(drive.powerVec),1);
% phaseLine=zeros(length(drive.powerVec),1);
% ampLine=zeros(length(drive.powerVec),1);
% phasePhotonCurrentLine=zeros(length(drive.powerVec),1);
% a2daga1Line=zeros(length(drive.powerVec),1);
% a1daga2Line=zeros(length(drive.powerVec),1);
% 
% a1daga1Line=zeros(length(drive.powerVec),1);
% a2daga2Line=zeros(length(drive.powerVec),1);
% a1Line=zeros(length(drive.powerVec),1);
% a2Line=zeros(length(drive.powerVec),1);
% expOLine=zeros(length(drive.powerVec),1);
% expOSquaredLine=zeros(length(drive.powerVec),1);
% 
% for jdx=1:length(drive.powerVec)
%     
%     rfgen.power = drive.powerVec(jdx);
% %     specgen.power = drive.powerVec(jdx);
%     pause(0.01);
%     
%     [moments]=photonCurrent_2ChanDigitalHomodyne(card,corrparams);
%     photonCurrentLine(jdx)=imag(moments.a1daga2-moments.a2daga1);
%     phaseLine(jdx)=angle(moments.a2)-angle(moments.a1);
%     ampLine(jdx)=abs(moments.a2)-abs(moments.a1);
% %     phasePhotonCurrentLine(jdx)=photonCurrentLine(jdx)./(-2*abs(moments.a1)*abs(moments.a2));
%     a2daga1Line(jdx)=moments.a2daga1;
%     a1daga2Line(jdx)=moments.a1daga2;
%     
%     a1daga1Line(jdx)=moments.a1daga1;
%     a2daga2Line(jdx)=moments.a2daga2;
%     a1Line(jdx)=moments.a1;
%     a2Line(jdx)=moments.a2;
%     
%     expOLine(jdx)=moments.expO;
%     expOSquaredLine(jdx)=moments.expOSquared;
%    
% end
% 
% photonCurrentMat(:,idx)=photonCurrentLine;
% expOMat(:,idx)=expOLine;
% expOSquaredMat(:,idx)=expOSquaredLine;
% phaseMat(:,idx)=unwrap(phaseLine);
% ampMat(:,idx)=ampLine;
% % phasePhotonCurrentMat(:,idx)=phasePhotonCurrentLine;
% a2daga1Mat(:,idx)=a2daga1Line;
% a1daga2Mat(:,idx)=a1daga2Line;
% 
% a1daga1Mat(:,idx)=a1daga1Line;
% a2daga2Mat(:,idx)=a2daga2Line;
% a1Mat(:,idx)=a1Line;
% a2Mat(:,idx)=a2Line;
% 
% f=figure(260);
% set(f,'Position', [50, 50, 695, 695]);
% subplot(3,2,1);
% imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,photonCurrentMat(:,1:idx));
% xlabel('Drive Frequency [GHz]');
% title([filename '_photonCurrent']);
% set(gca, 'YDir', 'normal');
% 
% 
% subplot(3,2,2);
% imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,abs(photonCurrentMat(:,1:idx)));
% xlabel('Drive Frequency [GHz]');
% title(['abs(photonCurrent)']);
% set(gca, 'YDir', 'normal');
% 
% subplot(3,2,3);
% imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,abs(expOMat(:,1:idx)).^2);
% xlabel('Drive Frequency [GHz]');
% title(['|<a_1+a_2>|']);
% set(gca, 'YDir', 'normal');
% 
% subplot(3,2,4);
% imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,expOSquaredMat(:,1:idx)-abs(expOMat(:,1:idx)).^2);
% xlabel('Drive Frequency [GHz]');
% ylabel('Drive Power [dBm]');
% title(['Variance of a_1+a_2']);
% set(gca, 'YDir', 'normal');
% 
% subplot(3,2,5);
% imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,a1daga1Mat(:,1:idx));
% xlabel('Drive Frequency [GHz]');
% ylabel('Drive Power [dBm]');
% title(['a1daga1']);
% set(gca, 'YDir', 'normal');
% 
% subplot(3,2,6);
% imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,a2daga2Mat(:,1:idx));
% xlabel('Drive Frequency [GHz]');
% ylabel('Drive Power [dBm]');
% title(['a2daga2']);
% set(gca, 'YDir', 'normal');
% 
% end
% 
% cardSettings=card.params.toStruct();
% saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\pulses_072517\';
%     isFolder = exist(saveFolder);
%     if isFolder == 0
%         mkdir(saveFolder)
%     end
% save([saveFolder filename '.mat'],...
%     'rfgen','logen','specgen','corrparams',...
%     'card','cardSettings','photonCurrentMat','expOMat',...
%     'expOSquaredMat','a1daga1Mat','a2daga2Mat','phaseMat','ampMat',...
%     'phasePhotonCurrentMat','a1Mat','cardSettings','a2Mat',...
%     'fileIdentifier','drive');
% savefig([saveFolder filename '.fig']);
% 
% 
% 
