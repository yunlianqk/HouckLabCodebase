addpath('C:\Users\Cheesesteak\Documents\GitHub\HouckLabMeasurementCode\JJR\TunableDimer')

%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.01;yoko1.rampinterval=.001;
yoko2.rampstep=.01;yoko2.rampinterval=.001;
yoko3.rampstep=.01;yoko3.rampinterval=.001;

CM = [.0845 -.00037 -.011; -.0034 0.5597 .0117; .54 -.51 2.3447;]; % update on 09/11
% f0 = [.2748; -.1975; 0.2319;]; % after power surge 7/18
% f0 = [.2748; -.1975; 0.064286;]; % after power surge 9/10
% f0 = [.2748; -0.1659; 0.064286;]; % 9/16
f0 = [.2748; -0.1659; 0.3358;];
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

for sdx = linspace(1,3,3)
    
    %% Update and read transmission channel
    pnax.SetActiveTrace(1);
    transWaitTime=120;
    pnax.params.start = 5.75e9;
    pnax.params.stop = 5.95e9;
    pnax.params.points = 3001;
    pnax.params.power = -34;
    pnax.params.averages = 65536;
    pnax.params.ifbandwidth = 10e3;
    pnax.ClearChannelAverages(1);
    ftrans = pnax.ReadAxis();
    
    clear vtraj ftraj
    
    if sdx == 1
        fstart=[0.0 0.0 0.0];
        fstop=[0.44 0 0.0];fsteps=100;
    elseif sdx == 2
        fstart=[0 -2.0 0];
        fstop=[0 2.0 0];fsteps=100;    
    else
        fstart=[0 0.0 -1.5];
        fstop=[0 0 1.5];fsteps=100;
    end
    vstart=fc.calculateVoltagePoint(fstart);vstop=fc.calculateVoltagePoint(fstop);
    vtraj=fc.generateTrajectory(vstart,vstop,fsteps);
    ftraj=fc.calculateFluxTrajectory(vtraj);
    fc.visualizeTrajectories(vtraj,ftraj);
    
    %% Transmission scan along trajectory
    tic; time=fix(clock);
    steps=size(vtraj,2); points=pnax.params.points; freqvector=pnax.ReadAxis();
    z = zeros(steps,points); transS21AlongTrajectoryAmp=z; transS21AlongTrajectoryPhase=z; transS41AlongTrajectoryAmp=z; transS41AlongTrajectoryPhase=z;
    fc.currentVoltage=vtraj(:,1);
    for index=1:steps
        if index==1
            tStart=tic;
            time=clock;
            if sdx == 1
                filename=['couplerFit_LeftInput_leftQubitScan_'  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
            elseif sdx == 2
                filename=['couplerFit_LeftInput_rightQubitScan_'  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
            else
                filename=['couplerFit_LeftInput_rightQubitScan_'  num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))];
            end
        end
        % update flux/voltage
        fc.currentVoltage=vtraj(:,index);
        % measure S21 and S41
        pnax.SetActiveTrace(1);
        pnax.ClearChannelAverages(1);
        pause(transWaitTime);
        pnax.SetActiveTrace(1);
        [data_transS21A data_transS21P] = pnax.ReadAmpAndPhase();
        pnax.SetActiveTrace(2);
        [data_transS41A data_transS41P] = pnax.ReadAmpAndPhase();
        
        transS21AlongTrajectoryAmp(index,:)=data_transS21A;
        transS21AlongTrajectoryPhase(index,:)=data_transS21P;
        transS41AlongTrajectoryAmp(index,:)=data_transS41A;
        transS41AlongTrajectoryPhase(index,:)=data_transS41P;
        
        figure(158);
        subplot(1,2,1);
        imagesc(ftrans/1e9,[1,index],transS21AlongTrajectoryAmp(1:index,:)); title(filename); ylabel('step');xlabel('S21 (Cross) Measurement');
        subplot(1,2,2);
        imagesc(ftrans/1e9,[1,index],transS41AlongTrajectoryAmp(1:index,:)); title(filename); ylabel('step');xlabel('S41 (Through) Measurement');
        
        if index==1
            deltaT=toc(tStart);
            estimatedTime=steps*deltaT*3;
            disp(['Estimated Time is '...
                num2str(estimatedTime/3600),' hrs, or '...
                num2str(estimatedTime/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(estimatedTime),'second'))]);
        end
    end
    pnaxSettings=pnax.params.toStruct();
    saveFolder = 'C:\Users\Cheesesteak\Documents\Mattias\tunableDimer\PNAX_Calibrations_072017\';
    save([saveFolder filename '.mat'],...
        'CM','f0','fc','transWaitTime','pnaxSettings','ftrans','ftraj','vtraj','time','steps',...
        'transS21AlongTrajectoryAmp','transS21AlongTrajectoryPhase','transS41AlongTrajectoryAmp','transS41AlongTrajectoryPhase')
    
    title(filename)
    savefig([saveFolder filename '.fig']);
    
    fc.visualizeTrajectories(vtraj,ftraj);
    title([filename '_traj'])
    savefig([saveFolder filename '_traj.fig']);
    toc
end
fc.currentVoltage=[0 0 0];
