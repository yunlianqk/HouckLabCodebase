function [ S21amp, S21freqvector,SpecAmp,SpecPhas,Specfreqvector ] = Ian_SpecScan( transCh1, specCh2,pnax,yoko,scanParam)
% Copied from AV_fluxSpecScan
    S21amp = nan(length(scanParam.yokoVector),transCh1.points);
    SpecPhas = nan(length(scanParam.yokoVector),specCh2.points);
    SpecAmp = nan(length(scanParam.yokoVector),specCh2.points);
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
    SetVoltage(yoko,scanParam.yokoVector(1));
    for index=1:length(scanParam.yokoVector)
        if index== 1
            tStart=tic;
        end
        SetVoltage(yoko,scanParam.yokoVector(index));
        pause(0.5);
        pnax.SetActiveTrace(transCh1.trace);
        pnax.AvgClear(1);
        pnax.TrigContinuous(1);
        pnax.AutoScaleAll();
        pause(scanParam.transwait)

        S21amp(index,:)=pnax.Read();
        pnax.TrigHold(1);
        figure(333)
        imagesc(S21freqvector/1e9,scanParam.yokoVector,S21amp);
        xlabel('Frequency(GHz)')
        ylabel('Yoko Voltage(V)')
        title('RF amp')
        
        [~, peak_ind]=max(S21amp(index,:));
        specCh2.cwfreq=S21freqvector(peak_ind);
        figure(111)
        plot(specCh2.cwfreq/1e9, scanParam.yokoVector(index),'ro'); hold on
        xlabel('Frequency (Ghz)')
        ylabel('Yoko voltage')
        title('RF amp')
        
        specCh2.format='MLOG';
        pnax.SetParams(specCh2);
        pnax.SetActiveTrace(specCh2.trace);
        pnax.AvgClear(2);
        pnax.TrigContinuous(2);
        pnax.AutoScaleAll();
        pause(scanParam.specwait)

        SpecAmp(index,:)=pnax.Read();
        pnax.TrigHold(2);

        figure(444)
        imagesc(Specfreqvector/1e9,scanParam.yokoVector,SpecAmp);
        xlabel('Frequency(GHz)')
        ylabel('Yoko Voltage(V)')
        title('Spec Amp')
        
        specCh2.format='PHAS';
        pnax.SetParams(specCh2);
        pnax.SetActiveTrace(specCh2.trace);
        pnax.AvgClear(2);
        pnax.TrigContinuous(2);
        pnax.AutoScaleAll();
        pause(scanParam.specwait)

        SpecPhas(index,:)=pnax.Read();
        pnax.TrigHold(2);

        figure(443)
        imagesc(Specfreqvector/1e9,scanParam.yokoVector,SpecPhas);
        xlabel('Frequency(GHz)')
        ylabel('Yoko Voltage(V)')
        title('Spec Phase')
        
        if index==1
            deltaT=toc(tStart);
            disp(['Estimated scan time is '...
                num2str(length(scanParam.yokoVector)*deltaT/3600) ' hours'])
        end
    end
    
    
    
end

