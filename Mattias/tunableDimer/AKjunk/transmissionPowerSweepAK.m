addpath('C:\Users\BFG\Documents\HouckLabMeasurementCode\JJR\TunableDimer')


%% setup date for saving 
time = clock;
runDate = datestr(time,'mmddyy');

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.002;yoko1.rampinterval=.01;
yoko2.rampstep=.002;yoko2.rampinterval=.01;
yoko3.rampstep=.002;yoko3.rampinterval=.01;


% these are leftover from before
% nla = 3.5; %new attenuation of left line
% nra = 2.9; %new attenuation of right line
% nca = 1.075; %new attenuation of coupler line
% cal_MAT = [.0845/nla      -.00037/nra     -.011/nca;     -.0034/nla      0.5597/nra      .0117/nca;      0.1535   -0.1765   2.1810];  %best guess from calibrated bottom row and old matrix, 6-21-17
% CM = cal_MAT;

% CM = [1 0 0; 0 1 0; 0 0 1];  %starter Matrix
% CM = [1 0 0; 0 1 0; 1/2.5 60/136 1/0.45];  %iteration3
% CM = [1 0 0; 0 1 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated 8/12 to include qubit effects on coupler  
% CM = [1 0 0; 0 1/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Changed the diagonal element for the right qubit  
CM = [0.07512 0 0; 0 0.9198/1.9 0; 120/(7*41) -120/(7*40) 1/0.45];  % Updated left and right qubit diagonal elements at 9:30 am on 8/17/17 

% f0 = [0; -0.2; -0.05]; % updated 08/17/17 at 12 pm
f0 = [0; -0.2; 0.0083]; % updated 08/22/17 at 6:30 pm
fc=fluxController(CM,f0);

fc2 = fluxController2;
EcLeft = 298e6;
EcRight = 298e6;
EjSumLeft = 25.420e9;
EjSumRight = 29.342e9;
fc2.leftQubitFluxToFreqFunc = @(x) sqrt(8.*EcLeft.*EjSumLeft.*abs(cos(pi.*x)))-EcLeft;
fc2.rightQubitFluxToFreqFunc = @(x) sqrt(8.*EcRight.*EjSumRight.*abs(cos(pi.*x)))-EcRight;

%% Update and read transmission channel
pnax.SetActiveTrace(1);
% transWaitTime=10;
% transWaitTime=10;
% transWaitTime=80;
% transWaitTime=320;
% transWaitTime=320*3/4/2;
% transWaitTime=320*3/4;
transWaitTime=320/2;
transWaitTime=100;

% pnax.params.start = 5.8e9;
% pnax.params.stop = 5.95e9;
pnax.params.start = 5.7e9;
pnax.params.stop = 6.0e9;

pnax.params.points = 2201;

% powerVec = linspace(-55,-10,20);
% powerVec = linspace(-65,-10,25);
% powerVec = linspace(-65,0,35);
% powerVec = [-45,-40,-25];
% powerVec = linspace(-70,-10,65);
% powerVec = linspace(-60,-25,20);
% powerVec = linspace(-35,5,32);
% powerVec = linspace(-35,5,20);
powerVec = linspace(-40,-10,15);

fResonanceLargeJ=[-0.088 0.28 0.0];
fResonanceSmallJ=[-0.088 0.28 0.35];
fDetunedLargeJ=[0.22 0.5 0.0];
fDetunedSmallJ=[0.22 0.5 0.35];

fQubitResonance = [-0.088 0.28];
fQubitDetuned = [0.22 0.5];
% fCouplerVec = linspace(0,0.35,5);
% fCouplerVec = [0 0.35 0.175 0.0875 0.2625]; %reordering of previous line so that I can stop it sunday afternoon if I want to and still have the full span of coupler values
% fCouplerVec = linspace(0,0.45,4);
fCouplerVec = [0];

% pnax.params.power = -35;
pnax.PowerOn()
pnax.params.averages = 65536;
pnax.params.ifbandwidth = 10e3;
pnax.ClearChannelAverages(1);
ftrans = pnax.ReadAxis();

%% Transmission power scan

% qubitSettings = [1 2];
% qubitSettings = [1]; %resonant
% qubitSettings = [2]; %detuned
qubitSettings = [3]; %wierd arbitrary place
for qdx = qubitSettings %loop over qubit condition
    for cdx = 1:length(fCouplerVec) %loop over coupler values
        if qdx ==1
            qubitPoint = fQubitResonance;

        elseif qdx == 2
            qubitPoint = fQubitDetuned;
        elseif qdx == 3;
            qubitPoint = [-0.088 -0.21];
        end
        fPoint = [qubitPoint fCouplerVec(cdx)];
        v = fc.calculateVoltagePoint(fPoint);

        voltageCutoff = 3.5;

        if abs(v)>voltageCutoff
            disp('VOLTAGE IS TOO HIGH')
            return
        end

        fc.currentVoltage=v;
        tic; time=fix(clock);
        transS21AlongTrajectoryAmp = zeros(length(powerVec),length(ftrans));
        transS21AlongTrajectoryPhase = zeros(length(powerVec),length(ftrans));
        transS41AlongTrajectoryAmp = zeros(length(powerVec),length(ftrans));
        transS41AlongTrajectoryPhase = zeros(length(powerVec),length(ftrans));
        for idx=1:length(powerVec)
            if idx==1
                tStart=tic;
                time=clock;
                timestr = datestr(time,'yyyymmdd_HHss'); %year(4)month(2)day(2)_hour(2)second(2), hour in military time
                fileTitle = 'PowerScan_leftInput_' ;
%                 fileTitle = 'PowerScan_rightInput_' ;
                if qdx==1
                    filename=[fileTitle 'resonance_coupler' num2str(fCouplerVec(cdx)) '_' (time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
                    AKfilename = [fileTitle 'resonance_coupler' num2str(fCouplerVec(cdx)) '_' timestr];
                    fignum =400+cdx;
                elseif qdx==2
%                     filename=[fileTitle 'detuned_' num2str(fCouplerVec(cdx)) '_' (time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
%                     AKfilename = [fileTitle 'detuned_' num2str(fCouplerVec(cdx)) '_' timestr];
                    filename=[fileTitle 'detuned_coupler' num2str(fCouplerVec(cdx)) '_' (time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
                    AKfilename = [fileTitle 'detuned_coupler' num2str(fCouplerVec(cdx)) '_' timestr];
                    fignum =700+cdx;
                elseif qdx==3
                    filename=[fileTitle 'arbitrary_coupler' num2str(fCouplerVec(cdx)) '_' (time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
                    AKfilename = [fileTitle 'arbitrary_coupler' num2str(fCouplerVec(cdx)) '_' timestr];
                    fignum =450+cdx;
%                 elseif tdx==2
%                     filename=['PowerScan_leftInput_rightOutput_fResonanceSmallJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
%                     fignum = 44;
%                 elseif tdx==3
%                     filename=['PowerScan_leftInput_rightOutput_fDetunedLargeJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
%                     fignum = 47;
%                 elseif tdx ==4
%                     filename=['PowerScan_leftInput_rightOutput_fDetunedSmallJ_'   num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
%                     fignum = 49;
                end

            end
            % update flux/voltage
            pnax.params.power = powerVec(idx);
            pnax.SetActiveTrace(1);
            pnax.ClearChannelAverages(1);
            pause(transWaitTime);
            pnax.SetActiveTrace(1);
            [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
            pnax.SetActiveTrace(2);
            pause(1);
            [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();

            transS21AlongTrajectoryAmp(idx,:)=data_transS21A;
            transS21AlongTrajectoryPhase(idx,:)=data_transS21P;

            transS41AlongTrajectoryAmp(idx,:)=data_transS41A;
            transS41AlongTrajectoryPhase(idx,:)=data_transS41P;

            %         figure(158);
            %         imagesc(ftrans/1e9,powerVec(1:idx),transS21AlongTrajectoryAmp(1:idx,:)); title(filename); ylabel('PNAX Power [dBm]');xlabel('S21 (Cross) Measurement');
            %
            hFig = figure(fignum);
            set(hFig, 'Position', [100 100 1000 600]);
            subplot(1,2,1);
            imagesc(ftrans/1e9,powerVec(1:idx),transS21AlongTrajectoryAmp(1:idx,:)); title(AKfilename); ylabel('step');xlabel('Right Output Frequency [GHz]');
            subplot(1,2,2);
            imagesc(ftrans/1e9,powerVec(1:idx),transS41AlongTrajectoryAmp(1:idx,:)); title(AKfilename); ylabel('step');xlabel('Left Output Frequency [GHz]');

            if idx==1 && qdx == min(qubitSettings) && cdx == 1
                deltaT=toc(tStart);
                estimatedTime=deltaT*length(powerVec)*length(qubitSettings)*length(fCouplerVec);
                disp(['Estimated Time is '...
                    num2str(estimatedTime/3600),' hrs, or '...
                    num2str(estimatedTime/60),' min']);
                disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                    round(estimatedTime),'second'))]);
            end
        end
        pnaxSettings=pnax.params.toStruct();

%         saveFolder = 'C:\Users\BFG\Documents\Mattias\tunableDimer\PNAX_Calibrations_082217\';
        saveFolder = ['C:\Users\BFG\Documents\Mattias\tunableDimer\PNAX_Calibrations_' runDate '\'];
        isFolder = exist(saveFolder);
        if isFolder == 0
            mkdir(saveFolder)
        end
        save([saveFolder filename '.mat'],...
            'CM','f0','fc','transWaitTime','pnaxSettings','ftrans','time','powerVec',...
            'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase')

        title(filename)
        savefig([saveFolder filename '.fig']);

        % fc.visualizeTrajectories(vtraj,ftraj);
        % title([filename '_traj'])
        % savefig([saveFolder filename '_traj.fig']);
        toc

        currFilePath = mfilename('fullpath');
%         savePath = [saveFolder filename 'AK' '.mat'];
        savePath = [saveFolder AKfilename 'AK' '.mat'];
        % funclib.save_all(savePath);
        funclib.save_all(savePath, currFilePath);

    end
end
fc.currentVoltage=[0 0 0];


% currFilePath = mfilename('fullpath');
% savePath = [saveFolder filename 'AK' '.mat'];
% % funclib.save_all(savePath);
% funclib.save_all(savePath, currFilePath);
