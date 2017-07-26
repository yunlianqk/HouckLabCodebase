%% Set AWG parameters
% Time axis: 0.8 ns sampling interval, 5 us total length
taxis = 0:0.8e-9:20e-6;
pulsegen1.timeaxis = taxis;
% % Channel 1: 1 MHz sine wave between 0 and 10 us
% pulsegen1.waveform1 = 1.0*(taxis <= 18e-6) .* (taxis > 1e-6);
% pulsegen1.waveform2 = 0.*taxis;

up = 0;

%sweep params
timeStep = 1.6e-9;
totalTime = 20e-6;

initializeTime = 10e-6;
rampTime = 100e-9;
holdTime = 8e-6;

if up == 0
    startVal = 0;
else
    startVal = 1;
end

%Set AWG parameters for up pulse or down pulse
% Time axis: 0.8 ns sampling interval, 5 us total length
taxis = 0:timeStep:totalTime;
pulsegen1.timeaxis = taxis;


rfgen.power = -5;
%finish the AWG pulse
Sec1 = startVal*ones(1,initializeTime/timeStep);
Sec2 = linspace(startVal,0.5,rampTime/timeStep);
Sec3 = 0.5*ones(1,holdTime/timeStep);
Remainder = zeros(1,length(taxis)-(length(Sec1)+length(Sec2)+length(Sec3)));
pulsegen1.waveform1 = [Sec1 Sec2 Sec3 Remainder] ;
pulsegen1.waveform2 = 0.*taxis;



%% Generate pulses
pulsegen1.Generate();
pulsegen1.marker2 = (taxis <= 200e-9).*(taxis > 100e-9);

% Plot waveforms and markers
figure(1);
subplot(2, 1, 1);
hold off;
plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform1);
hold on;
plot(pulsegen1.timeaxis/1e-6, pulsegen1.marker2, 'r');
title('Channel 1');
legend('Waveform', 'Marker');
subplot(2, 1, 2);
hold off;
plot(pulsegen1.timeaxis/1e-6, pulsegen1.waveform2/max(abs(pulsegen1.waveform2)));
hold on;
plot(pulsegen1.timeaxis/1e-6, pulsegen1.marker4, 'r');
xlabel('Time (\mus)');
title('Channel 2');


%% Set up Generators

rfgen.ModOn();
specgen.ModOn();

rfgen.PowerOn()
logen.PowerOn()
rfgen.freq = 5.899e9;
logen.freq = 5.899e9;
rfgen.power = -10;
logen.power = 11.5;

%% Set Up Card Parameters

triggen.period = 0e-6;

cardparams = paramlib.acqiris();
cardparams.fullscale = 1.0;
cardparams.offset = 0e-6;

timeDuration = 12e-6;
cardparams.sampleinterval = 1e-9;
cardparams.samples = timeDuration/cardparams.sampleinterval;
cardparams.averages = 1;
cardparams.segments = 1;
cardparams.delaytime = 9e-6;
cardparams.couplemode = 'DC';
cardparams.trigPeriod = 30e-6;

card.SetParams(cardparams);

% Time axis in us
timeaxis = (0:card.params.samples-1)*card.params.sampleinterval/1e-6;

%% Acquire data

[Idata, Qdata] = card.ReadIandQ();

% Plot data
figure(1);
subplot(3,1,1);
plot(timeaxis, Idata);
title('In-phase');
ylabel('V_I (V)');

subplot(3,1,2);
plot(timeaxis, Qdata);
ylabel('V_Q (V)');
xlabel('Time (\mus)');

subplot(3,1,3);
plot(timeaxis, Idata.^2+Qdata.^2);
title('Amplitude');
ylabel('V_Q (V)');
xlabel('Time (\mus)');

%%
addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.01;yoko1.rampinterval=.001;
yoko2.rampstep=.01;yoko2.rampinterval=.001;
yoko3.rampstep=.01;yoko3.rampinterval=.001;

% CM = [.0845 -.00037 -.011; -.0034 0.5597 .0117; .54 -.51 2.3447;]; % update on 09/11
% CM = [1.0 0.00 0.0; 0.00 1.0 0.00; 0 0.0 2.3447*0.9302;]; % update on 09/11

% cal_MAT = [1.0  0.0  0.0; 0.0  0.1704   0.0; 0.1535   -0.1765   2.1810];  %voltage to flux conversion matrix, best guess from 6-21-17

nla = 3.5; %new attenuation of left line
nra = 2.9; %new attenuation of right line
nca = 1.075; %new attenuation of coupler line
cal_MAT = [.0845/nla      -.00037/nra     -.011/nca;     -.0034/nla      0.5597/nra      .0117/nca;      0.1535   -0.1765   2.1810];  %best guess from calibrated bottom row and old matrix, 6-21-17
% cal_MAT = [1.0  0.0  0.0; 0.0  1.0   0.0; 0.1535   -0.1765   2.3447*0.9302];  %voltage to flux conversion matrix
CM = cal_MAT;
% CM = inv(cal_MAT)

% f0 = [.2748; -.1975; 0.2319;]; % after power surge 7/18
% f0 = [.2748; -.1975; 0.064286;]; % after power surge 9/10
% f0 = [.2748; -0.1659; 0.064286;]; % 9/16

% f0 = [.2748; -0.1659; 0.3358 - 0.3333;]; %first try 6-21-17 Doesn't work with best guess matrix

% f0 = [0; 0.4557; 0.3358 - 0.3333;];  %freq min of right qubit is at zero
% f0 = [0; -0.1443; 0.3358 - 0.3333;];  %freq max of right qubit is at zero
f0 = [0.01; -0.1443; 0.3358 - 0.3333;]; %freq max of right qubit is at zero


% f0 = [0; -.1975; -.348;]; % from reboot before power surge
% f0 = [0; -.1975; -.1655;];   from before reboot
fc=fluxController(CM,f0);

fc2 = fluxController2;
EcLeft = 298e6;
EcRight = 298e6;
EjSumLeft = 25.420e9;
EjSumRight = 29.342e9;
fc2.leftQubitFluxToFreqFunc = @(x) sqrt(8.*EcLeft.*EjSumLeft.*abs(cos(pi.*x)))-EcLeft;
fc2.rightQubitFluxToFreqFunc = @(x) sqrt(8.*EcRight.*EjSumRight.*abs(cos(pi.*x)))-EcRight;

%% Set up Scan
clear IDataMat QDataMat ampDataMat

drive.powerVec = linspace(-7,5,60);
drive.freqVec = linspace(5.887e9,5.89e9,10);
for rep = 1
    for fdx = 1:length(drive.freqVec)
        
        for up = [0 1]
            
            fResonance=[0.0143 0.275 0.0];
            fDetuned=[-0.1 0.0091 0.0];
            
            f = fResonance;
            v=fc.calculateVoltagePoint(f);
            fc.currentVoltage = v;
            
            drive.freq = drive.freqVec(fdx);
            
            rfgen.freq = drive.freq;
            logen.freq = drive.freq;
            
            %sweep params
            timeStep = 1.6e-9;
            totalTime = 20e-6;
            
            initializeTime = 10e-6;
            rampTime = 200e-9;
            holdTime = 8e-6;
            
%             maxVal = 0.0;
%             minVal = -20.0;
%             
%             maxValLinear = 10^((maxVal-30)/10);
%             minValLinear = 10^((minVal-30)/10);
%             maxMinRatio = minValLinear/maxValLinear;
%             
            if up == 0
                startVal = 0;
            else
                startVal = 1;
            end
            

            
            
%             %     endvalVec = linspace(2.0,1.0,120);
%             endvalVec = linspace(maxMinRatio,1,56);
%             endvalPowers = linspace(minVal,maxVal,length(endvalVec));
            
            
            
            %setup storage
            IDataMat = zeros(length(drive.powerVec),int16(cardparams.samples));
            QDataMat = zeros(length(drive.powerVec),int16(cardparams.samples));
            ampDataMat = zeros(length(drive.powerVec),int16(cardparams.samples));
            cardparams.averages = 1;
            
            %Set AWG parameters for up pulse or down pulse
            % Time axis: 0.8 ns sampling interval, 5 us total length
            taxis = 0:timeStep:totalTime;
            pulsegen1.timeaxis = taxis;
            
            
            for idx=1:length(drive.powerVec)
                
                rfgen.power = drive.powerVec(idx);
                %finish the AWG pulse
                Sec1 = startVal*ones(1,initializeTime/timeStep);
                Sec2 = linspace(startVal,0.5,rampTime/timeStep);
                Sec3 = 0.5*ones(1,holdTime/timeStep);
                Remainder = zeros(1,length(taxis)-(length(Sec1)+length(Sec2)+length(Sec3)));
                pulsegen1.waveform1 = [Sec1 Sec2 Sec3 Remainder] ;
                pulsegen1.waveform2 = 0.*taxis;
                
                % Generate pulses
                pulsegen1.Generate();
                pulsegen1.marker2 = (taxis <= 200e-9).*(taxis > 100e-9);
                
                
                if idx==1
                    tStart = tic;
                    time = clock;
                    filename=['hysteresisUD_rightDrive_rightOutput_' num2str(drive.freq/1e9) 'GHz' num2str(time(1)) num2str(time(2)) num2str(time(3))...
                        num2str(time(5)) num2str(time(6))];
                end
                
                
                
                [IData, QData] = card.ReadIandQ();
                IDataMat(idx,:) = IData(1:int16(cardparams.samples));
                QDataMat(idx,:) = QData(1:int16(cardparams.samples));
                ampDataMat(idx,:) = sqrt(IDataMat(idx,:).^2 + QDataMat(idx,:).^2);
                
                pause(0.1)
                
                %store data
                if up ==0
                    IDataMat_up = IDataMat;
                    QDataMat_up = QDataMat;
                    ampDataMat_up = ampDataMat;
                    column = 0;
                    titleStr = 'down';
                elseif up == 1
                    IDataMat_down = IDataMat;
                    QDataMat_down = QDataMat;
                    ampDataMat_down = ampDataMat;
                    column = 1;
                    titleStr = 'up';
                end
                
                figure(33);
                %             subplot(3,1,1);
                %             imagesc(timeaxis,endvalPowers(1:idx), IDataMat(1:idx,:)); xlabel('time [\mu s]');
                %             suptitle(filename)
                %             title(['I_' titleStr])
                %             subplot(3,1,2);
                %             imagesc(timeaxis,endvalPowers(1:idx) ,QDataMat(1:idx,:)); xlabel('time [\mu s]');
                %             title(['Q_' titleStr])
                %             subplot(3,1,3);
                imagesc(timeaxis,drive.powerVec(1:idx) ,ampDataMat(1:idx,:)); xlabel('time [\mu s]');
                title([filename ', |abd|^2 _' titleStr])
            end
            if up ==0
                savefig([saveFolder filename  '_down.fig']);
            elseif up ==1
                savefig([saveFolder filename  '_up.fig']);
            end
        end
        
        saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\pulses_072517\';
        if exist(saveFolder)==0
            mkdir(saveFolder)
        end
        save([saveFolder filename '.mat'],...
            'drive','IDataMat_up','QDataMat_up','ampDataMat_up','IDataMat_down','QDataMat_down','ampDataMat_down','timeaxis');
        
        savefig([saveFolder filename '.fig']);
        
    end
end

% %% Set up Scan old version without preper hysteresis start
% clear IDataMat QDataMat ampDataMat
% 
% 
% up = 1;
% 
% for up = [0 1]
%     
% %     timeStep = 0.8e-9;
% %     totalTime = 20e-6;
% %     
% %     initializeTime = 10e-6;
% %     rampTime = 100e-9;
% %     holdTime = 8e-6;
% %     
% %     if up == 0
% %         startVal = 0;
% %     else
% %         startVal = 1;
% %     
% %     %Set AWG parameters for up pulse or down pulse
% %     % Time axis: 0.8 ns sampling interval, 5 us total length
% %     taxis = 0:timeStep:totalTime;
% %     pulsegen1.timeaxis = taxis;
% %     % Channel 1: 1 MHz sine wave between 0 and 10 us
% % 
% %     
% %     Sec1 = startVal*ones(initializeTime/timeStep);
% %     Sec2 = linspace(startVal,0.5,rampTime/timeStep);
% %     Sec3 = 0.5*ones(holdTime/timeStep);
% %     Remainder = zeros(length(taxis)-(length(Sec1)+length(Sec2)+length(Sec3)));
% %     pulsegen1.waveform1 = [Sec1 Sec2 Sec3 Remainder] ;
% %     pulsegen1.waveform2 = 0.*taxis;
% % 
% %     % Generate pulses
% %     pulsegen1.Generate();
% %     pulsegen1.marker2 = (taxis <= 200e-9).*(taxis > 100e-9) 
% 
% 
%    
% 
%     drive.powerVec = linspace(2.0,1.0,120);
% 
%     fResonance=[0.0143 0.275 0.0];
%     fDetuned=[-0.1 0.0091 0.0];
% 
%     f = fResonance;
%     v=fc.calculateVoltagePoint(f);
% 
%     drive.freq = 5.889e9;
% 
%     rfgen.freq = drive.freq;
%     logen.freq = drive.freq;
% 
%     IDataMat = zeros(length(drive.powerVec),int16(cardparams.samples));
%     QDataMat = zeros(length(drive.powerVec),int16(cardparams.samples));
%     ampDataMat = zeros(length(drive.powerVec),int16(cardparams.samples));
%     cardparams.averages = 1;
% 
%     for idx=1:length(drive.powerVec)
%         rfgen.power = drive.powerVec(idx);
% 
%         if idx==1
%             tStart = tic;
%             time = clock;
%             if pdx == 1
%             filename=['hysteresis_rightDrive_rightOutput' num2str(time(1)) num2str(time(2)) num2str(time(3))... 
%                 num2str(time(5)) num2str(time(6))]
%             if pdx == 0
%         end
% 
%         [IData, QData] = card.ReadIandQ(); 
%         IDataMat(idx,:) = IData(1:int16(cardparams.samples));
%         QDataMat(idx,:) = QData(1:int16(cardparams.samples));
%         ampDataMat(idx,:) = sqrt(IDataMat(idx,:).^2 + QDataMat(idx,:).^2);
% 
%         pause(0.1)
%         figure(33);
%         subplot(3,1,1);
%         imagesc(timeaxis,drive.powerVec(1:idx), IDataMat(1:idx,:)); xlabel('time [\mu s]'); title(filename)
%         subplot(3,1,2);
%         imagesc(timeaxis,drive.powerVec(1:idx) ,QDataMat(1:idx,:)); xlabel('time [\mu s]');
%         subplot(3,1,3);
%         imagesc(timeaxis,drive.powerVec(1:idx) ,ampDataMat(1:idx,:)); xlabel('time [\mu s]');
%     end
% 
%     saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\pulses_072417\';
%     save([saveFolder filename '.mat'],...
%         'drive','IDataMat','QDataMat','ampDataMat','timeaxis');
% 
%     savefig([saveFolder filename '.fig']);
% 
% end
% 

%% Sit at a power and look at single shots

% cardparams.averages = 1;
% 
% 
% for idx = 1:length(30)
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
% pause
