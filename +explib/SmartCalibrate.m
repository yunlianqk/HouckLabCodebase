function pulseCal = SmartCalibrate(pulseCal, awg, card, cardparams)
% Fine calibrations for pulses. Repeats the amp calibrations until error is below .005 mrads

    display('Beginning Calibration')
    %%
    tic
    display('X180 Rabi')
    cardparams.averages=50;
    card.SetParams(cardparams);
    ampVector = linspace(0,1,26);
    softwareAverages = 5;
    x = explib.X180RabiExperiment(pulseCal, ampVector, softwareAverages);
    playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    display(['Old X180 Amplitude: ' num2str(pulseCal.X180Amplitude)])
    pulseCal.X180Amplitude = result.newAmp;
    pulseCal.X90Amplitude = result.newAmp/2;
    pulseCal.Xm90Amplitude = result.newAmp/2;
    pulseCal.Y180Amplitude = result.newAmp;
    pulseCal.Y90Amplitude = result.newAmp/2;
    pulseCal.Ym90Amplitude = result.newAmp/2;
    display(['New X180 Amplitude: ' num2str(pulseCal.X180Amplitude)])
    toc
    %% X90 Drag cal
    display(' ')
    display(' ')
    display('X90 Drag cal')
    cardparams.averages=50;
    card.SetParams(cardparams);
    ampVector = linspace(-.4,.4,51);
    softwareAverages = 5;
    x = explib.X90DragCal(pulseCal, ampVector, softwareAverages);
    playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    display(['Old X90, Xm90 Drag Amplitude: ' num2str(pulseCal.X90DragAmplitude)])
    pulseCal.X90DragAmplitude = result.newDragAmp;
    pulseCal.Xm90DragAmplitude = result.newDragAmp;
    pulseCal.Y90DragAmplitude = -1*result.newDragAmp;
    pulseCal.Ym90DragAmplitude = -1*result.newDragAmp;
    display(['New X90, Xm90 Drag Amplitude: ' num2str(pulseCal.X90DragAmplitude)])
    
    %% very fine X90 amp cal using error amplification
    tic
    display(' ')
    display(' ')
    display('X90 amp cal')
    cardparams.averages=50;
    card.SetParams(cardparams);
    numGateVector = 0:2:80; % list of # of pi/2 gates to be done. MUST BE EVEN
    softwareAverages = 20;
    x = explib.X90AmpCal(pulseCal, numGateVector, softwareAverages);
    playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    display(['Old X90, Xm90 Amplitude: ' num2str(pulseCal.X90Amplitude)])
    pulseCal.X90Amplitude = result.newAmp;
    pulseCal.Xm90Amplitude = result.newAmp;
    pulseCal.Y90Amplitude = result.newAmp;
    pulseCal.Ym90Amplitude = result.newAmp;
    display(['New X90, Xm90 Amplitude: ' num2str(pulseCal.X90Amplitude)])
    toc