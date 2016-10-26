function pulseCal = RecalibrateContinuous(initialPulseCal, awg, card, cardparams)
    % repeatedly calibrates pulses. Includes stop window to gracefully
    % finish calibrations.
    pulseCal = initialPulseCal;
    time=fix(clock);
    FS = funclib.stoploop('Stop Continuous Recalibration');
    while(~FS.Stop())
        display('')
        display('Beginning next round of calibration')
        pulseCal = explib.Recalibrate(pulseCal, awg, card, cardparams);
        save(['C:\Data\Calibration_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
            'cardparams','pulseCal');
    end
    FS.Clear();