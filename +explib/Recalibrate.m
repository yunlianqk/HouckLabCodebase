function updatedPulseCal = Recalibrate(initialPulseCal, awg, card, cardparams, varargin)
    % Fine calibrations for pulses. Repeats the calibration repNum times.
    if ~isempty(varargin)
        repNum = varargin{1};
    else
        repNum = 1;
    end
    
    updatedPulseCal = initialPulseCal;
    totalCalTime = tic;
    time=fix(clock);
    display('Beginning Calibration')
    
    % repeat calibration
    for ind = 1:repNum
        
        tic
        display(' ')
        display('X90 Coarse Amplitude Calibration')
        tic;
        cardparams.averages=50;
        card.SetParams(cardparams);
        numGateVector = 0:2:20; % list of # of pi/2 gates to be done. MUST BE EVEN
        softwareAverages = 10;
        x = explib.X90AmpCal(updatedPulseCal, numGateVector, softwareAverages);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        display(['Old X90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
        updatedPulseCal.X90Amplitude = result.newAmp;
        updatedPulseCal.Xm90Amplitude = result.newAmp;
        updatedPulseCal.Y90Amplitude = result.newAmp;
        updatedPulseCal.Ym90Amplitude = result.newAmp;
        display(['New X90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
        toc
        
        display(' ')
        display('X90 Drag Calibration')
        tic;
        cardparams.averages=50;
        card.SetParams(cardparams);
        ampVector = linspace(-.2,.2,51);
        softwareAverages = 20;
        x = explib.X90DragCal(updatedPulseCal, ampVector, softwareAverages);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        display(['Old X90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
        updatedPulseCal.X90DragAmplitude = result.newDragAmp;
        updatedPulseCal.Xm90DragAmplitude = result.newDragAmp;
        updatedPulseCal.Y90DragAmplitude = -1*result.newDragAmp;
        updatedPulseCal.Ym90DragAmplitude = -1*result.newDragAmp;
        display(['New X90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
        
        tic
        display(' ')
        display('X90 Coarse Amplitude Calibration')
        tic;
        cardparams.averages=50;
        card.SetParams(cardparams);
        numGateVector = 0:2:40; % list of # of pi/2 gates to be done. MUST BE EVEN
        softwareAverages = 10;
        x = explib.X90AmpCal(updatedPulseCal, numGateVector, softwareAverages);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        display(['Old X90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
        updatedPulseCal.X90Amplitude = result.newAmp;
        updatedPulseCal.Xm90Amplitude = result.newAmp;
        updatedPulseCal.Y90Amplitude = result.newAmp;
        updatedPulseCal.Ym90Amplitude = result.newAmp;
        display(['New X90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
        toc
        
        display(' ')
        display('X90 Drag Calibration')
        tic;
        cardparams.averages=50;
        card.SetParams(cardparams);
        ampVector = linspace(-.2,.2,51);
        softwareAverages = 20;
        x = explib.X90DragCal(updatedPulseCal, ampVector, softwareAverages);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        display(['Old X90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
        updatedPulseCal.X90DragAmplitude = result.newDragAmp;
        updatedPulseCal.Xm90DragAmplitude = result.newDragAmp;
        updatedPulseCal.Y90DragAmplitude = -1*result.newDragAmp;
        updatedPulseCal.Ym90DragAmplitude = -1*result.newDragAmp;
        display(['New X90 Drag Amplitude: ' num2str(updatedPulseCal.X90DragAmplitude)])
        
        tic
        display(' ')
        display('X90 Fine Amplitude Calibration')
        tic;
        cardparams.averages=50;
        card.SetParams(cardparams);
        numGateVector = 0:2:80; % list of # of pi/2 gates to be done. MUST BE EVEN
        softwareAverages = 20;
        x = explib.X90AmpCal(updatedPulseCal, numGateVector, softwareAverages);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        display(['Old X90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
        updatedPulseCal.X90Amplitude = result.newAmp;
        updatedPulseCal.Xm90Amplitude = result.newAmp;
        updatedPulseCal.Y90Amplitude = result.newAmp;
        updatedPulseCal.Ym90Amplitude = result.newAmp;
        display(['New X90 Amplitude: ' num2str(updatedPulseCal.X90Amplitude)])
        toc
        
        display(' ')
        display('X180 Coarse Amplitude Calibration')
        tic;
        cardparams.averages=50;
        card.SetParams(cardparams);
        numGateVector = 0:1:20; % list of # of pi/2 gates to be done. MUST BE EVEN
        softwareAverages = 10;
        x = explib.X180AmpCal(updatedPulseCal, numGateVector, softwareAverages);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        display(['Old X180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
        updatedPulseCal.X180Amplitude = result.newAmp;
        updatedPulseCal.Xm180Amplitude = result.newAmp;
        updatedPulseCal.Y180Amplitude = result.newAmp;
        updatedPulseCal.Ym180Amplitude = result.newAmp;
        display(['New X180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
        toc
        
        display(' ')
        display('X180 Drag Calibration')
        tic;
        cardparams.averages=50;
        card.SetParams(cardparams);
        ampVector = linspace(-.2,.3,51);
        softwareAverages = 20;
        x = explib.X180DragCal(updatedPulseCal, ampVector, softwareAverages);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        display(['Old X180 Drag Amplitude: ' num2str(updatedPulseCal.X180DragAmplitude)])
        updatedPulseCal.X180DragAmplitude = result.newDragAmp;
        updatedPulseCal.Xm180DragAmplitude = result.newDragAmp;
        updatedPulseCal.Y180DragAmplitude = -1*result.newDragAmp;
        updatedPulseCal.Ym180DragAmplitude = -1*result.newDragAmp;
        display(['New X180 Drag Amplitude: ' num2str(updatedPulseCal.X180DragAmplitude)])
        toc
        
        display(' ')
        display('X180 Fine Amplitude Calibration')
        tic;
        cardparams.averages=50;
        card.SetParams(cardparams);
        numGateVector = 0:1:40; % list of # of pi/2 gates to be done. MUST BE EVEN
        softwareAverages = 20;
        x = explib.X180AmpCal(updatedPulseCal, numGateVector, softwareAverages);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        display(['Old X180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
        updatedPulseCal.X180Amplitude = result.newAmp;
        updatedPulseCal.Xm180Amplitude = result.newAmp;
        updatedPulseCal.Y180Amplitude = result.newAmp;
        updatedPulseCal.Ym180Amplitude = result.newAmp;
        display(['New X180 Amplitude: ' num2str(updatedPulseCal.X180Amplitude)])
        toc
        
        display(' ')
        display(['Calibration Time: '])
        toc(totalCalTime)
    end
end