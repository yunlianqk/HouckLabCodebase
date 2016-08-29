function [S21amp, S21freqvector,SpecAmp,Specfreqvector,transCh1,specCh2]=AV_fluxSpecScan(transCh1,specCh2,pnax,yoko,scanParam)
% Scan for transmission and spec as a function of Yoko voltage

% initialize scan vectors
S21amp=zeros(length(scanParam.yokoVector),transCh1.points);
% S21phase=zeros(length(scanParam.yokoVector),transCh1.points);
SpecAmp=zeros(length(scanParam.yokoVector),specCh2.points);
% SpecPhase=zeros(length(scanParam.yokoVector),specCh2.points);


% Setup transmission channel 1
pnax.SetParams(transCh1);
pnax.AvgOn();
pnax.TrigContinuous(1);
pnax.AutoScaleAll()
pause(5)
S21freqvector=pnax.ReadAxis();
pnax.TrigHold(1);

% Setup spec channel 2
pnax.SetParams(specCh2);
pnax.AvgOn();
pnax.TrigContinuous(2);
pnax.AutoScaleAll()
pause(5)
Specfreqvector=pnax.ReadAxis();
pnax.TrigHold(2);

pnax.TrigHoldAll();

for index=1:length(scanParam.yokoVector)
    if index== 1
        tStart=tic;
    end
    
    
    SetVoltage(yoko,scanParam.yokoVector(index));
    pause(0.5);
    
    % Transmissiioon measurement
    pnax.SetActiveTrace(transCh1.trace);
    pnax.AvgClear(1);
    pnax.TrigContinuous(1);
    pnax.AutoScaleAll();
    pause(scanParam.transwait)
    
    S21amp(index,:)=pnax.Read();
    pnax.TrigHold(1);
    
    figure(333)
    imagesc(S21freqvector/1e9,scanParam.yokoVector(1:index),S21amp(1:index,:));
    xlabel('Frequency(GHz)')
    ylabel('Yoko Voltage(V)')
    
    % find transmission peak
    [m,peak]=max(S21amp(index,:));
    % update spec CW freq
    specCh2.cwfreq=S21freqvector(peak);
    figure(111)
    plot(specCh2.cwfreq/1e9, scanParam.yokoVector(index),'ro'); hold on
    xlabel('Frequency (Ghz)')
    ylabel('Yoko voltage')
    xlim([6.62, 6.65])
    
    %Spec measurment
    pnax.SetParams(specCh2);
    pnax.SetActiveTrace(specCh2.trace);
    pnax.AvgClear(2);
    pnax.TrigContinuous(2);
    pnax.AutoScaleAll();
    pause(scanParam.specwait)
    
    SpecAmp(index,:)=pnax.Read();
    pnax.TrigHold(2);
    
    figure(444)
    imagesc(Specfreqvector/1e9,scanParam.yokoVector(1:index),SpecAmp(1:index,:));
    xlabel('Frequency(GHz)')
    ylabel('Yoko Voltage(V)')
    
    
    
    if index==1
        deltaT=toc(tStart);
        disp(['Estimated scan time is '...
            num2str(length(scanParam.yokoVector)*deltaT/3600) ' hours'])
    end
end
SetVoltage(yoko,0);
end