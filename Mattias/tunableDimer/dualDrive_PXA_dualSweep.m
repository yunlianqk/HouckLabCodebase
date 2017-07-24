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


%% PXA params

pxa.bw=0.5e6;
pxa.video=6e3;
pxa.start=5.8e9;
pxa.stop=5.95e9;
pxa.averageCount=3000;
pxa.numPoints=2001;

freqVec = linspace(pxa.start,pxa.stop,pxa.numPoints);

waitTime=1.5;
%%

fResonance=[0.0143 0.275 0.0];
fDetuned=[-0.1 0.0091 0.0];

f = fResonance;
v=fc.calculateVoltagePoint(f);

%%
fc.currentVoltage=v;


leftDrive.PowerOff();
rightDrive.PowerOff();

pxa.AvgClear;
pause(10)
measuredEmission_background = pxa.Read();    

leftDrive.PowerOn();
rightDrive.PowerOn();
    
drive.powerVec = linspace(-5,-55,11);
drive.freqVec=linspace(5.8e9,5.95e9,1400);

% measuredEmission = zeros(length(drive.freqVec),pxa.numPoints);
% measuredEmissionSubtracted = zeros(length(drive.freqVec),pxa.numPoints);

for pdx = 1:length(drive.powerVec)
    measuredEmission = zeros(length(drive.freqVec),pxa.numPoints);
    measuredEmissionSubtracted = zeros(length(drive.freqVec),pxa.numPoints);
    leftDrive.power = drive.powerVec(pdx);
    rightDrive.power = drive.powerVec(pdx);
    for idx=1:length(drive.freqVec)
        
        leftDrive.freq = drive.freqVec(idx);
        rightDrive.freq = drive.freqVec(idx);
%         rightDrive.freq = 5.9094e9;
        if idx==1
            tStart = tic;
            time = clock;
            filename=['dualDrive_rightOutput_PXA_drivePower' num2str(drive.powerVec(pdx)) '_' num2str(time(1)) num2str(time(2)) num2str(time(3))...
                num2str(time(4)) num2str(time(5))];
%             filename=['dualDrive_PXA_rightDriveFixed5.9094GHz_drivePower' num2str(drive.powerVec(pdx)) '_' num2str(time(1)) num2str(time(2)) num2str(time(3))...
%                 num2str(time(4)) num2str(time(5))];
        end
        
        pxa.AvgClear;
        pause(waitTime);
        measuredEmission(idx,:) = pxa.Read();
        measuredEmissionSubtracted(idx,:) = measuredEmission(idx,:) - measuredEmission_background;
        
        if idx == 1;
            deltaT=toc(tStart);
            estimatedTime=deltaT*length(drive.freqVec)*length(drive.powerVec);
            disp(['Estimated Time is '...a
                num2str(estimatedTime/3600),' hrs, or '...
                num2str(estimatedTime/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(estimatedTime),'second'))]);
        end
        
        
        figure(2);
        imagesc(freqVec/1e9,drive.freqVec(1:idx),measuredEmissionSubtracted(1:idx,:));
        xlabel('Emission Frequency [GHz]');
        ylabel('Drive Frequency [GHz]');
        title([filename]);
        colorbar();
        
        
        
    end
    saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\PXA_Calibrations_072317\';
    save([saveFolder filename '.mat'],...
        'leftDrive','rightDrive','measuredEmission', 'pxa','freqVec','drive');
    
    savefig([saveFolder filename '.fig']);
end

