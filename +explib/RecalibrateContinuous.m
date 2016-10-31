function pulseCal = RecalibrateContinuous(initialPulseCal, awg, card, cardparams)
    % repeatedly calibrates pulses. Includes stop window to gracefully
    % finish calibrations.
    pulseCal = initialPulseCal;
    time=fix(clock);
    FS = funclib.stoploop('Stop Continuous Recalibration');
    calibN = 1;
    
    X90dragVect=[];
    X90ampVect=[];
    X180dragVect=[];
    X180ampVect=[];
    
    while(~FS.Stop())
        display('')
        display('Beginning next round of calibration')
        pulseCal = explib.Recalibrate(pulseCal, awg, card, cardparams);
%         save(['C:\Data\Calibration_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
%             'cardparams','pulseCal');
        % Plot calibration parameters as a function of time
        X90dragVect=[X90dragVect,pulseCal.X90DragAmplitude];
        X90ampVect=[X90ampVect,pulseCal.X90Amplitude];
        X180dragVect=[X180dragVect,pulseCal.X180DragAmplitude];
        X180ampVect=[X180ampVect,pulseCal.X180Amplitude];

        calibNvect=(1:1:calibN);
        figure(505)
        subplot(2,2,1)
        plot(calibNvect,X90dragVect,'--ok')
        title('X90 Drag evolution');
        ylabel('X90 Drag amplitude');xlabel('Calibration #');
        subplot(2,2,3)
        plot(calibNvect,X90ampVect,'--or')
        title('X90 Amplitude evolution');
        ylabel('X90 amplitude');xlabel('Calibration #');
        subplot(2,2,2)
        plot(calibNvect,X180dragVect,'--ok')
        title('X180 Drag evolution');
        ylabel('X180 Drag amplitude');xlabel('Calibration #');
        subplot(2,2,4)
        plot(calibNvect,X180ampVect,'--or')
        title('X180 Amplitude evolution');
        ylabel('X180 amplitude');xlabel('Calibration #');
        drawnow
        calibN = calibN + 1;
        
    end
    FS.Clear();