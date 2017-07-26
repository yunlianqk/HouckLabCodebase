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


% Tune the yokos to the proper place
fResonanceLargeJ=[0.0143 0.275 0.0];
fResonanceSmallJ=[0.0143 0.275 0.35];
fDetunedLargeJ=[-0.1 0.0091 0.0];
fDetunedSmallJ=[-0.1 0.0091 0.35];

v = fc.calculateVoltagePoint(fDetunedLargeJ);
fc.currentVoltage=v;


%% Set AWG parameters
triggen.period = 10e-6;
% Time axis: 0.8 ns sampling interval, 5 us total length
taxis = 0:0.8e-9:10e-6;
pulsegen1.timeaxis = taxis;
pulsegen1.waveform1 = ones(1,length(taxis));
pulsegen1.waveform2 = pulsegen1.waveform1;
pulsegen1.Generate();
pulsegen1.marker2 = (taxis <= 200e-9).*(taxis > 100e-9);

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


%% Set up Generators

rfgen.ModOff();
% specgen.ModOff();

rfgen.PowerOn();

specgen.PowerOff();

logen.PowerOn();

corrparams.Int_Freq = 5e6;
% corrparams.LPF = 10e3;
corrparams.LPF = 1e6;

rfgen.freq = 5.899e9;
specgen.freq = 5.899e9;
logen.freq = rfgen.freq+corrparams.IF;

%% Set Up Card Parameters

cardparams = paramlib.acqiris();
cardparams.fullscale = 1.0;
cardparams.offset = 0e-6;

timeDuration = 2e-6;
cardparams.sampleinterval = 1e-9;
cardparams.samples = timeDuration/cardparams.sampleinterval;
cardparams.averages = 200000;
cardparams.segments = 1;
cardparams.delaytime = 6e-6;
cardparams.couplemode = 'DC';
cardparams.trigPeriod = 10e-6;

corrparams.limCount=1;

card.SetParams(cardparams);

% Time axis in us
timeaxis = (0:card.params.samples-1)*card.params.sampleinterval/1e-6;

%% Acquire data

rfgen.power = -20;
specgen.power = -20;
pause(0.01);

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

triggen.offset=1;
triggen.vpp=2;

logen.power = 13.5;
logen.PowerOn();

% drive.powerVec = linspace(-40,5,20);
drive.powerVec = linspace(-55,-15,80);
% drive.freqVec = linspace(5.818e9,5.89e9,5);
drive.freqVec = linspace(5.8e9,5.95e9,25);

warning('off','all');

clear rfparams moments photonCurrentMat phasePhotonCurrentMat...
    a1a2Mat phaseMat ampMat ...
    a2daga1Mat a1daga2Mat a1daga1Mat ...
    a2daga2Mat a1Mat a2Mat

photonCurrentMat=zeros(length(drive.powerVec),length(drive.freqVec));
photonCurrentMatNormalized=zeros(length(drive.powerVec),length(drive.freqVec));
phaseMat=zeros(length(drive.powerVec),length(drive.freqVec));
ampMat=zeros(length(drive.powerVec),length(drive.freqVec));
phasePhotonCurrentMat=zeros(1,length(drive.powerVec),length(drive.freqVec));
a2daga1Mat=zeros(length(drive.powerVec),length(drive.freqVec));
a1daga2Mat=zeros(length(drive.powerVec),length(drive.freqVec));
h2h1dagMat=zeros(length(drive.powerVec),length(drive.freqVec));
h1h2dagMat=zeros(length(drive.powerVec),length(drive.freqVec));
expOMat=zeros(length(drive.powerVec),length(drive.freqVec));
expOSquaredMat=zeros(length(drive.powerVec),length(drive.freqVec));

a1daga1Mat=zeros(length(drive.powerVec),length(drive.freqVec));
a2daga2Mat=zeros(length(drive.powerVec),length(drive.freqVec));
a1Mat=zeros(length(drive.powerVec),length(drive.freqVec));
a2Mat=zeros(length(drive.powerVec),length(drive.freqVec));



tStart = tic;
time = clock;
fileIdentifier='2channelDigitalHomodyne';

filename=['pC_leftInput_' num2str(time(1)) num2str(time(2)) num2str(time(3))...
    num2str(time(4)) num2str(time(5))];

for idx = 1:length(drive.freqVec)

clear photonCurrentLine a2daga1Line ...
    a1daga2Line a1daga1Line ...
    a2daga2Line phasePhotonCurrentLine ...
    phaseLine ampLine a1Line a2Line

photonCurrentLine=zeros(length(drive.powerVec),1);
phaseLine=zeros(length(drive.powerVec),1);
ampLine=zeros(length(drive.powerVec),1);
phasePhotonCurrentLine=zeros(length(drive.powerVec),1);
a2daga1Line=zeros(length(drive.powerVec),1);
a1daga2Line=zeros(length(drive.powerVec),1);

a1daga1Line=zeros(length(drive.powerVec),1);
a2daga2Line=zeros(length(drive.powerVec),1);
a1Line=zeros(length(drive.powerVec),1);
a2Line=zeros(length(drive.powerVec),1);
expOLine=zeros(length(drive.powerVec),1);
expOSquaredLine=zeros(length(drive.powerVec),1);

for jdx=1:length(drive.powerVec)
    
    rfgen.power = drive.powerVec(jdx);
%     specgen.power = drive.powerVec(jdx);
    pause(0.01);
    
    [moments]=photonCurrent_2ChanDigitalHomodyne(card,corrparams);
    photonCurrentLine(jdx)=imag(moments.a1daga2-moments.a2daga1);
    phaseLine(jdx)=angle(moments.a2)-angle(moments.a1);
    ampLine(jdx)=abs(moments.a2)-abs(moments.a1);
%     phasePhotonCurrentLine(jdx)=photonCurrentLine(jdx)./(-2*abs(moments.a1)*abs(moments.a2));
    a2daga1Line(jdx)=moments.a2daga1;
    a1daga2Line(jdx)=moments.a1daga2;
    
    a1daga1Line(jdx)=moments.a1daga1;
    a2daga2Line(jdx)=moments.a2daga2;
    a1Line(jdx)=moments.a1;
    a2Line(jdx)=moments.a2;
    
    expOLine(jdx)=moments.expO;
    expOSquaredLine(jdx)=moments.expOSquared;
   
end

photonCurrentMat(:,idx)=photonCurrentLine;
expOMat(:,idx)=expOLine;
expOSquaredMat(:,idx)=expOSquaredLine;
phaseMat(:,idx)=unwrap(phaseLine);
ampMat(:,idx)=ampLine;
% phasePhotonCurrentMat(:,idx)=phasePhotonCurrentLine;
a2daga1Mat(:,idx)=a2daga1Line;
a1daga2Mat(:,idx)=a1daga2Line;

a1daga1Mat(:,idx)=a1daga1Line;
a2daga2Mat(:,idx)=a2daga2Line;
a1Mat(:,idx)=a1Line;
a2Mat(:,idx)=a2Line;

f=figure(260);
set(f,'Position', [50, 50, 695, 695]);
subplot(3,2,1);
imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,photonCurrentMat(:,1:idx));
xlabel('Drive Frequency [GHz]');
title([filename '_photonCurrent']);
set(gca, 'YDir', 'normal');


subplot(3,2,2);
imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,abs(photonCurrentMat(:,1:idx)));
xlabel('Drive Frequency [GHz]');
title(['abs(photonCurrent)']);
set(gca, 'YDir', 'normal');

subplot(3,2,3);
imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,abs(expOMat(:,1:idx)).^2);
xlabel('Drive Frequency [GHz]');
title(['|<a_1+a_2>|']);
set(gca, 'YDir', 'normal');

subplot(3,2,4);
imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,expOSquaredMat(:,1:idx)-abs(expOMat(:,1:idx)).^2);
xlabel('Drive Frequency [GHz]');
ylabel('Drive Power [dBm]');
title(['Variance of a_1+a_2']);
set(gca, 'YDir', 'normal');

subplot(3,2,5);
imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,a1daga1Mat(:,1:idx));
xlabel('Drive Frequency [GHz]');
ylabel('Drive Power [dBm]');
title(['a1daga1']);
set(gca, 'YDir', 'normal');

subplot(3,2,6);
imagesc(drive.freqVec(1:idx)/1e9,drive.powerVec,a2daga2Mat(:,1:idx));
xlabel('Drive Frequency [GHz]');
ylabel('Drive Power [dBm]');
title(['a2daga2']);
set(gca, 'YDir', 'normal');

end

cardSettings=card.params.toStruct();
saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\pulses_072517\';
    isFolder = exist(saveFolder);
    if isFolder == 0
        mkdir(saveFolder)
    end
save([saveFolder filename '.mat'],...
    'rfgen','logen','specgen','corrparams',...
    'card','cardSettings','photonCurrentMat','expOMat',...
    'expOSquaredMat','a1daga1Mat','a2daga2Mat','phaseMat','ampMat',...
    'phasePhotonCurrentMat','a1Mat','cardSettings','a2Mat',...
    'fileIdentifier','drive');
savefig([saveFolder filename '.fig']);


