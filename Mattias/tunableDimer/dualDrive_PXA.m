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

%% PXA params

pxa.bw=0.5e6;
pxa.video=6e3;
pxa.start=5.8e9;
pxa.stop=5.95e9;
pxa.averageCount=3000;
pxa.numPoints=2001;

waitTime = 2;
%%

rfgen.PowerOn();
specgen.PowerOn();
    
drive.powerVec = linspace(-55,-15,60);
drive.freqVec = linspace(5.8e9,5.95e9,20);

measuredEmission = zeros(length(drive.powerVec),length(drive.freqVec));

for fdx = 1:length(drive.freqVec)
    rfgen.freq = drive.freqVec(fdx);
    specgen.freq = drive.freqVec(fdx);
    
    pxa.bw=1e3;
    pxa.video=10e3;
    pxa.start=rfgen.freq-10e3;
    pxa.stop=rfgen.freq+10e3;
    pxa.averageCount=3000;
    pxa.numPoints=220;
    
    pxaFreq = linspace(pxa.start,pxa.stop,pxa.numPoints);
   
    for idx=1:length(drive.powerVec)
        
        specgen.power = drive.powerVec(idx);
        rfgen.power = drive.powerVec(idx);
        if (idx == 1 && fdx==1)
            tStart = tic;
            time = clock;
            filename=['leftDrive_rightOutput_PXA_' num2str(time(1)) num2str(time(2)) num2str(time(3))...
                num2str(time(4)) num2str(time(5))];
        end
        
        pxa.AvgClear;
        pause(waitTime);
        measuredEmissionTemp = pxa.Read();        
        
%         figure(21);
%         plot(measuredEmissionTemp)
%         title(measuredEmissionTemp(pxa.numPoints/2))
        
        measuredEmission(idx,fdx) = measuredEmissionTemp(pxa.numPoints/2);

        
        if (fdx == 1 && idx == 1)
            deltaT=toc(tStart);
            estimatedTime=deltaT*length(drive.freqVec)*length(drive.powerVec);
            disp(['Estimated Time is '...a
                num2str(estimatedTime/3600),' hrs, or '...
                num2str(estimatedTime/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(estimatedTime),'second'))]);
        end
           
        
    end
    
    figure(2);
    imagesc(drive.freqVec(1:fdx)/1e9,drive.powerVec,measuredEmission(:,1:fdx));
    xlabel('Drive Frequency [GHz]');
    ylabel('Drive Power [dBm]');
    set(gca, 'YDir', 'normal');
    title([filename]);
    colorbar();

end

saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\pulse_072517\';
isFolder = exist(saveFolder);
if isFolder == 0
    mkdir(saveFolder)
end
save([saveFolder filename '.mat'],...
    'drive','measuredEmission','pxa','rfgen','logen');