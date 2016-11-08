function [ params ] = Ian_Auto_correction( driveFreq,measFreq)
    path = 'C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\';
    addpath(genpath(path));
    run('C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\instruments_initialize.m');
    set(0,'DefaultFigureWindowStyle','docked')

    %Sync pulsegen and pulsegen2
    pulsegen2.SyncWith(pulsegen1);
    pulsegen1.Generate();
    params = measlib.QLifeTime.Params();
    instr = measlib.QPulseMeas.Instr();
    RabiMeas = measlib.Rabi();
    RamseyMeas = measlib.Ramsey();
    %Set up parameters
    params.driveSigma = 5e-9;
    params.driveFreq = driveFreq;%9.275e9 + 3e6;
    params.drivePower =-6;
    params.measFreq = measFreq;%7.664e9;
    params.measPower = -20;
    params.intFreq = 0; %detunning
    params.loPower = 11;
    params.measDuration = 1e-6;
    params.tStep = 0.01e-6;
    params.numSteps = 41;
    params.numAvg = 65536;
    params.trigPeriod = 40e-6;
    params.cardDelay = 0e-6;

    GateMeas.params = params;
    
    instr.qpulsegen = pulsegen1;
    instr.mpulsegen = pulsegen2;
    instr.rfgen = rfgen;
    instr.specgen = specgen;
    instr.logen = logen;
    instr.digitizer = card;
    instr.triggen = triggen;

    RabiMeas.instr = instr;
    T1Meas.instr = instr;
    RamseyMeas.instr = instr;
    EchoMeas.instr = instr;

    RabiMeas.params = params;
    RabiMeas.params.trigPeriod = 15e-6;
    RabiMeas.run();
    RabiMeas.data.tRange = [0.5e-6, 1.5e-6];
    Rabiresult = RabiMeas.fitData();
    
    %adjuct drive power based on Rabiresult
    params.drivePower = params.drivePower - 20*log10(Rabiresult/pi);
    % Do Ramsey experiment to find the qubit frequency
    RamseyMeas.params = params;
    % do ramsey to correct drive freq
    RamseyMeas.params.tStep = 0.01e-6;
    RamseyMeas.params.numSteps = 101;
    RamseyMeas.params.trigPeriod = 15e-6;
    RamseyMeas.params.driveFreq = params.driveFreq;
    RamseyMeas.run();

    RamseyMeas.data.tRange = [0.5e-6, 1.5e-6];
    RamseyMeas.fitData();
    detunning1 = FFT_Ramsey(RamseyMeas);
    
    %Rerun Ramsey to find the sign
    RamseyMeas.params.driveFreq = params.driveFreq + detunning1/2;
    RamseyMeas.run();
    RamseyMeas.fitData();
    detunning2 = FFT_Ramsey(RamseyMeas);
    if detunning1<detunning2
        % prediction is correct
        params.driveFreq = params.driveFreq + detunning1;
    else
         params.driveFreq = params.driveFreq - detunning1;
    end
    
end

 

function [detunning] = FFT_Ramsey(RamseyMeas)
    % FFT find frequency detunning
    temp_I = RamseyMeas.data.intdataI;
    temp_Q = RamseyMeas.data.intdataQ;

    T = RamseyMeas.params.tStep;
    L = RamseyMeas.params.numSteps;
    % t = 0:T:1e-6;
    Fs = 1/T;
    f = Fs*(0:(L/2))/L;
    Y_I = fft(temp_I);
    Y_Q = fft(temp_Q);

    P2_I = abs(Y_I/L);   
    P2_Q = abs(Y_Q/L);

    P1_I = P2_I(1:L/2+1);
    P1_Q = P2_Q(1:L/2+1);
    P1_I(2:end-1) = 2*P1_I(2:end-1);
    P1_Q(2:end-1) = 2*P1_Q(2:end-1);

    figure(112)
    subplot(2,1,1)
    plot(f/1e6,P1_I)
    title('FFT of Ramsey  I')
    xlabel('f (MHz)')
    ylabel('Amp')
    
    subplot(2,1,2)
    plot(f/1e6,P1_Q)
    title('FFT of Ramsey Q')
    xlabel('f (MHz)')
    ylabel('Amp')
    
    Max_I = max(P1_I);
    [~, loc_I] = findpeaks(P1_I,'MinPeakHeight', 0.1*Max_I);
    Max_Q = max(P1_Q);
    [~, loc_Q] = findpeaks(P1_Q,'MinPeakHeight', 0.1*Max_Q);
     % The frequency detunning is either +f(loc) or -f(loc)
    detunning = (f(loc_I) + f(loc_Q))/2;
    
    
end