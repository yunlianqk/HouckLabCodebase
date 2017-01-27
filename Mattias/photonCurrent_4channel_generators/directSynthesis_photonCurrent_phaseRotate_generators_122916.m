%%%%%%%%%%%%%%% INTIALIZATIONS
% CHECKLIST
% m8195a SFP open, with the following setting adjustments
%   - Clock tab: routing to Ref clock in(connected to the Rb clk)
%   - Output tab: chan 1V amp, Ch2(LO) 200mV amp (don't forget warm amp!)
%                 ch3(marker) 1V amp +0.5V offset
%   - Trigger tab: Trigger/Gate, Advance Event -> Trigger Inaddpath('C:\Users\newforce\Documents\GitHub\HouckLabMeasurementCode');


%%
% % Initialize awg object
% % cd 'C:\Users\Administrator\Documents\GitHub\HouckLabMeasurementCode'
% addpath('C:\Users\Administrator\Documents\GitHub\HouckLabMeasurementCode');
% % Choose settings in IQ config window -> press Ok
% % Import FIR filter -> press Ok
% awg = M8195AWG();
% 
%%

% address='PXI0::CHASSIS1::SLOT2::FUNC0::INSTR'; % PXI address
% card=M9703ADigitizer64(address);  % create object
% 
% card.params=paramlib.m9703a();   %default parameters


%% Set flux controller with crosstalk matrix and offset vector
% defined by f_vector = CM*v_vector + f_0   and vector is [lq; rq; cp]
yoko1.rampstep=.01;yoko1.rampinterval=.001;
yoko2.rampstep=.01;yoko2.rampinterval=.001;
yoko3.rampstep=.01;yoko3.rampinterval=.001;

CM = [.0845 -.00037 -.011; -.0034 0.5597 .0117; .54 -.51 2.3447;]; % update on 09/11
% f0 = [.2748; -.1975; 0.2319;]; % after power surge 7/18
% f0 = [.2748; -.1975; 0.064286;]; % after power surge 9/10
f0 = [.2748; -0.1659; 0.064286;]; % 9/16
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


for res=1

%% get mode frequencies

load('D:\tunableDimer\couplerFit_112816\optimalFit_allFreeParams_112816.mat');

splittingVec=omegaPlus(pOptimal,phiVec)-omegaMinus(pOptimal,phiVec);
minSplitting=min(splittingVec);
maxSplitting=max(splittingVec);

% splittingNumPoints=4;
% linearSplittingVec=linspace(maxSplitting,minSplitting,splittingNumPoints);

% splittingNumPoints=10;
% linearSplittingVec=linspace(minSplitting,62e6,splittingNumPoints);

splittingNumPoints=6;
linearSplittingVec=linspace(minSplitting,58e6,splittingNumPoints);

% splittingNumPoints=1;
% linearSplittingVec=linspace(57e6,57e6,splittingNumPoints);

for idx=1:length(linearSplittingVec)
    if linearSplittingVec(idx)==minSplitting
        splitIndexVec(idx)=length(splittingVec);
    elseif linearSplittingVec(idx)==maxSplitting
        splitIndexVec(idx)=1;
    else
        splitIndexVec(idx)=find(splittingVec<linearSplittingVec(idx),1);
    end
end

splitFluxVec=phiExtVec(splitIndexVec);
omegaPlusVec=omegaPlus(pOptimal,phiVec(splitIndexVec));
omegaMinusVec=omegaMinus(pOptimal,phiVec(splitIndexVec));
centerFreqVec=(omegaMinusVec+omegaPlusVec)./2;

clear vtraj ftraj
for idx=1:splittingNumPoints
    if res==1
        vtraj(:,idx)=fc.calculateVoltagePoint([fc2.calculateLeftQubitFluxFromFrequency(centerFreqVec(idx)) fc2.calculateRightQubitFluxFromFrequency(centerFreqVec(idx)) splitFluxVec(idx)]);
    else
        vtraj(:,idx)=fc.calculateVoltagePoint([0 0 splitFluxVec(idx)]);
    end
end
ftraj=fc.calculateFluxTrajectory(vtraj);
% fc.visualizeTrajectories(vtraj,ftraj);

%%

% clear IData QData Amp integratedAmp
% cardAcquisitionTime=1.0e-6;
% card.params.samples=cardAcquisitionTime*card.params.samplerate;
% card.params.fullscale=1;
% card.params.offset=0.00;
% card.params.segments=1;
% card.params.delaytime=0.5e-6;
% card.params.couplemode='DC';
% card.params.averages=1 ;

corrparams.limCount=20;

% taxisCard=linspace(0,cardAcquisitionTime,card.params.samples);

%%
% triggen.period=6.25e-6;
triggen.offset=1;
triggen.vpp=2;

logen.power = 18.5;
logen.PowerOn();

rfgen.ModOff;
specgen.ModOff;

for ldx=1:length(linearSplittingVec)
    
    fc.currentVoltage=vtraj(:,ldx);
    
    
    warning('off','all');
    clear rfparams moments photonCurrentMat ...
        a1a2Mat phaseMat ampMat ...
        a2daga1Mat a1daga2Mat a1daga1Mat ...
        a2daga2Mat a1Mat a2Mat
    
    % convert linear Vpp to dBm
    ampVec=linspace(0.01,1.25,20);
    linearPowerVec=((ampVec./200).^2)*100;
    powerVec=30+10*log10(linearPowerVec);
    
    leftDrive.powerVec=powerVec;
    rightDrive.powerVec=powerVec;
    rightDrive.phaseVec=linspace(-2*pi, 0, 20);
    
    % Readout pulse parameters
    leftDrive.Freq=centerFreqVec(ldx);
    rightDrive.Freq=centerFreqVec(ldx);
    
    rfgen.freq=leftDrive.Freq;
    specgen.freq=rightDrive.Freq;
    logen.freq=centerFreqVec(ldx);

    waveLength=10e-6;
    numTrigPeriods=round(waveLength*logen.freq);
    triggen.period=numTrigPeriods/logen.freq;
    card.params.trigPeriod=triggen.period;
    
    % get data for offset
    specgen.PowerOff();
    rfgen.PowerOff();
%     updateAWG_generators_v1(awg,leftDrive,rightDrive,mark,waveLength,rampTime);
    dataMatrix_off=card.ReadChannels64([2 3 4 5]);

    % turn back on the generators
    rfgen.PowerOn();
    specgen.PowerOn();
    
    photonCurrentMat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    photonCurrentMatNormalized=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    phaseMat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    ampMat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    phasePhotonCurrentMat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    a2daga1Mat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    a1daga2Mat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    h2h1dagMat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    h1h2dagMat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    expOMat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    expOSquaredMat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    
    a1daga1Mat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    a2daga2Mat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    a1Mat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    a2Mat=zeros(length(leftDrive.powerVec),length(rightDrive.powerVec));
    
    counter=1;
    
    f=figure(260);
    set(f,'Position', [50, 50, 695, 695]);
    for idx=1:length(rightDrive.phaseVec)
        clear photonCurrentLine a2daga1Line ...
            a1daga2Line a1daga1Line ...
            a2daga2Line phasePhotonCurrentLine ...
            phaseLine ampLine a1Line a2Line
        
        if counter==1
            tStart = tic;
            time = clock;
            fileIdentifier='4channelHomodyne_1p9MHzFilter_phaseRotate';
            if res==1
                filename=['pC_centerFreq_resonance_phaseSweep_generators_splitting' num2str(linearSplittingVec(ldx)/1e6) num2str(time(1)) num2str(time(2)) num2str(time(3))...
            num2str(time(4)) num2str(time(5))];
            else
                filename=['pC_centerFreq_detuned_phaseSweep_generators_splitting' num2str(linearSplittingVec(ldx)/1e6) num2str(time(1)) num2str(time(2)) num2str(time(3))...
            num2str(time(4)) num2str(time(5))];   
            end
        end
        
        specgen.phase = rightDrive.phaseVec(idx);
%         disp(num2str(rightDrive.phase))
        
        photonCurrentLine=zeros(length(leftDrive.powerVec),1);
        phaseLine=zeros(length(leftDrive.powerVec),1);
        ampLine=zeros(length(leftDrive.powerVec),1);
        phasePhotonCurrentLine=zeros(length(leftDrive.powerVec),1);
        a2daga1Line=zeros(length(leftDrive.powerVec),1);
        a1daga2Line=zeros(length(leftDrive.powerVec),1);
        
        a1daga1Line=zeros(length(leftDrive.powerVec),1);
        a2daga2Line=zeros(length(leftDrive.powerVec),1);
        a1Line=zeros(length(leftDrive.powerVec),1);
        a2Line=zeros(length(leftDrive.powerVec),1);
        expOLine=zeros(length(leftDrive.powerVec),1);
        expOSquaredLine=zeros(length(leftDrive.powerVec),1);
        
        for jdx=1:length(leftDrive.powerVec)
    
            rfgen.power = leftDrive.powerVec(jdx);
            specgen.power = rightDrive.powerVec(jdx);
            pause(0.01)
%             updateAWG_generators_v1(awg,leftDrive,rightDrive,mark,waveLength,rampTime);
            
            [moments]=photonCurrent_4chanHomodyne_v5(card,corrparams,dataMatrix_off);
            photonCurrentLine(jdx)=imag(moments.a1daga2-moments.a2daga1);
            phaseLine(jdx)=angle(moments.a2)-angle(moments.a1);
            ampLine(jdx)=abs(moments.a2)-abs(moments.a1);
            phasePhotonCurrentLine(jdx)=photonCurrentLine(jdx)./(-2*abs(moments.a1)*abs(moments.a2));
            a2daga1Line(jdx)=moments.a2daga1;
            a1daga2Line(jdx)=moments.a1daga2;
            
            a1daga1Line(jdx)=moments.a1daga1;
            a2daga2Line(jdx)=moments.a2daga2;
            a1Line(jdx)=moments.a1;
            a2Line(jdx)=moments.a2;
            
            expOLine(jdx)=moments.expO;
            expOSquaredLine(jdx)=moments.expOSquared;
            
            if counter == 1;
                deltaT=toc(tStart);
                estimatedTime=deltaT*length(leftDrive.powerVec)*length(rightDrive.phaseVec)*length(linearSplittingVec);
                disp(['Estimated Time is '...
                    num2str(estimatedTime/3600),' hrs, or '...
                    num2str(estimatedTime/60),' min']);
                disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                    round(estimatedTime),'second'))]);
            end
            counter=counter+1;
        end
        photonCurrentMat(:,idx)=photonCurrentLine;
        expOMat(:,idx)=expOLine;
        expOSquaredMat(:,idx)=expOSquaredLine;
        phaseMat(:,idx)=unwrap(phaseLine);
        ampMat(:,idx)=ampLine;
        phasePhotonCurrentMat(:,idx)=phasePhotonCurrentLine;
        a2daga1Mat(:,idx)=a2daga1Line;
        a1daga2Mat(:,idx)=a1daga2Line;
        
        a1daga1Mat(:,idx)=a1daga1Line;
        a2daga2Mat(:,idx)=a2daga2Line;
        a1Mat(:,idx)=a1Line;
        a2Mat(:,idx)=a2Line;
        
        
        subplot(3,2,1);
        imagesc(rightDrive.phaseVec(1:idx),leftDrive.powerVec,photonCurrentMat(:,1:idx));
        xlabel('Phase');
        ylabel('Drive Power ');
        title([filename '_photonCurrent']);
        set(gca, 'YDir', 'normal');
        colorbar();
        
        subplot(3,2,2);
        imagesc(rightDrive.phaseVec(1:idx),leftDrive.powerVec,abs(photonCurrentMat(:,1:idx)));
        xlabel('Phase ');
        ylabel('Drive Power ');
        title(['abs(photonCurrent)']);
        set(gca, 'YDir', 'normal');
        colorbar();
        
        subplot(3,2,3);
        imagesc(rightDrive.phaseVec(1:idx),leftDrive.powerVec,abs(expOMat(:,1:idx)).^2);
        xlabel('Phase ');
        ylabel('Drive Power ');
        title(['|<a_1+a_2>|']);
        set(gca, 'YDir', 'normal');
        colorbar();
        
        subplot(3,2,4);
        imagesc(rightDrive.phaseVec(1:idx),leftDrive.powerVec,expOSquaredMat(:,1:idx)-abs(expOMat(:,1:idx)).^2);
        xlabel('Phase ');
        ylabel('Drive Power ');
        title(['Variance of a_1+a_2']);
        set(gca, 'YDir', 'normal');
        colorbar();
        
        subplot(3,2,5);
        imagesc(rightDrive.phaseVec(1:idx),leftDrive.powerVec,a1daga1Mat(:,1:idx));
        xlabel('Phase');
        ylabel('Drive Power ');
        title(['a1daga1']);
        set(gca, 'YDir', 'normal');
        colorbar();
        
        subplot(3,2,6);
        imagesc(rightDrive.phaseVec(1:idx),leftDrive.powerVec,a2daga2Mat(:,1:idx));
        xlabel('Phase');
        ylabel('Drive Power ');
        title(['a2daga2']);
        set(gca, 'YDir', 'normal');
        colorbar();

        
        if mod(counter,10)==0
            cardSettings=card.params.toStruct();
            save([filename '.mat'],...
                'rfgen','logen','specgen','corrparams',...
                'card','leftDrive','rightDrive','photonCurrentMat','expOMat',...
                'expOSquaredMat','a1daga1Mat','a2daga2Mat','phaseMat','ampMat',...
                'phasePhotonCurrentMat','a1Mat','cardSettings','a2Mat','linearSplittingVec','fileIdentifier');
        end
        
    end
    cardSettings=card.params.toStruct();
    
    save([filename '.mat'],...
        'rfgen','logen','specgen','corrparams',...
        'card','leftDrive','rightDrive','photonCurrentMat','expOMat',...
        'expOSquaredMat','a1daga1Mat','a2daga2Mat','phaseMat','ampMat',...
        'phasePhotonCurrentMat','a1Mat','cardSettings','a2Mat','linearSplittingVec','fileIdentifier');
    savefig([filename '.fig']);
    
end
end
funclib.matlabmail('mattiasfitzpatrick777@gmail.com', ['Scan has finished'],...
    'Scan Finished', 'mattiasfitzpatrick777@gmail.com', 'Tias11235813?');

warning('on','all')

