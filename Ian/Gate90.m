function [pulse pulsem] = Gate90( pulse, pulsem, Id ,GateMeas )
    %amp error correct pulse
    maxNum = 21 +2 ; % last two gates are 2 * pi/2 and identity
    gateArray((maxNum+1)/2, maxNum) = Id;
    for row = 1:(maxNum+1)/2
        for col = 1:maxNum-row*2+1
            gateArray(row, col) = Id;
        end
        for col = maxNum-(row-1)*2:maxNum
            gateArray(row, col) = pulse;
        end
    end
    gateArray(end,:) = Id;% all identity gates
    gateArray(end-1,:) = Id;
    gateArray(end-1,end-1:end) = pulse; % two pulse gates

    GateMeas.qPulse = gateArray;
    % Run experiment
    GateMeas.params.trigPeriod = 20e-6;
    GateMeas.run();
    GateMeas.data.tRange = [0.5e-6, 1.5e-6];
    GateMeas.plotData();

    I_data = GateMeas.data.intdataI;
    Q_data = GateMeas.data.intdataQ;

    I_2pulse = I_data(end-1);
    I_I = I_data(end);
    normalized_I = (I_data(1:end-2) - I_I)/(I_2pulse-I_I);


    Q_2pulse = Q_data(end-1);
    Q_I = Q_data(end);
    normalized_Q = (Q_data(1:end-2)-Q_I)/(Q_2pulse-Q_I);
    figure(22)
    plot(normalized_I)
    hold on 
    plot(normalized_Q)
    hold off

    amp_ratio = 0.5 *(amp_correction90(2:2:maxNum - 3,normalized_Q)...
        + amp_correction90(2:2:maxNum - 3,normalized_I));
    
    pulse.amplitude = pulse.amplitude * amp_ratio;
    
    
     %amp error correct pulsem
    clear('gateArray');
    maxNum = 21 +2 ; % last two gates are 2 * pi/2 and identity
    gateArray((maxNum+1)/2, maxNum) = Id;
    for row = 1:(maxNum+1)/2
        for col = 1:maxNum-row*2+1
            gateArray(row, col) = Id;
        end
        for col = maxNum-(row-1)*2:maxNum
            gateArray(row, col) = pulsem;
        end
    end
    gateArray(end,:) = Id;% all identity gates
    gateArray(end-1,:) = Id;
    gateArray(end-1,end-1:end) = pulsem; % two pulse gates

    GateMeas.qPulse = gateArray;
    % Run experiment
    GateMeas.params.trigPeriod = 20e-6;
    GateMeas.run();
    GateMeas.data.tRange = [0.5e-6, 1.5e-6];
    GateMeas.plotData();

    I_data = GateMeas.data.intdataI;
    Q_data = GateMeas.data.intdataQ;

    I_2pulse = I_data(end-1);
    I_I = I_data(end);
    normalized_I = (I_data(1:end-2) - I_I)/(I_2pulse-I_I);


    Q_2pulse = Q_data(end-1);
    Q_I = Q_data(end);
    normalized_Q = (Q_data(1:end-2)-Q_I)/(Q_2pulse-Q_I);
    figure(22)
    plot(normalized_I)
    hold on 
    plot(normalized_Q)
    hold off

    amp_ratio = 0.5 *(amp_correction90(2:2:maxNum - 3,normalized_Q)...
        + amp_correction90(2:2:maxNum - 3,normalized_I));
    
    pulsem.amplitude = pulsem.amplitude * amp_ratio;
    
    %Drag error
    
    draglambda_ls = linspace(-2,2,60);
    I_d = nan(length(draglambda_ls),1);
    Q_d = nan(length(draglambda_ls),1);
    
    for i = 1:length(draglambda_ls)
        draglambda = draglambda_ls(i);
        Id = pulselib.singleGate('Identity');

        pulse.dragAmplitude =draglambda;
        
        clear('gateArray');

        gateArray(1,1) = pulse;
        gateArray(1,2) = pulsem;
        GateMeas.qPulse = gateArray;

        GateMeas.params.trigPeriod = 25e-6;
        GateMeas.run();
        GateMeas.data.tRange = [0.5e-6, 1.5e-6];
        GateMeas.plotData();
        I_d(i) = GateMeas.data.intdataI;
        Q_d(i) = GateMeas.data.intdataQ;

        figure(997)
        subplot(2,1,1)
        plot(draglambda_ls,I_d)
        title('I_dX90')
        xlabel('# of experiment')
        ylabel('VI')
        subplot(2,1,2)
        plot(draglambda_ls,Q_d)
        title('Q_dX90')
        xlabel('# of experiment')
        ylabel('VQ')
    end
    delta_I = max(I_d) * 0.5;
    [~, mintab_I] = peakdet(I_d,delta_I,draglambda_ls);
    [~,ind_I]  = min(abs(mintab_I(:,1)));

    delta_Q = max(Q_d) * 0.5;

    [~, mintab_Q] = peakdet(Q_d,delta_Q,draglambda_ls);
    [~,ind_Q]  = min(abs(mintab_Q(:,1)));
    pulse.dragAmplitude = 0.5 * (mintab_Q(ind_Q,1) + mintab_I(ind_I,1));
    pulsem.dragAmplitude = 0.5 * (mintab_Q(ind_Q,1) + mintab_I(ind_I,1));
    
    % Amp error 
    clear('gateArray');
    gateArray((maxNum+1)/2, maxNum) = Id;
    for row = 1:(maxNum+1)/2
        for col = 1:maxNum-row*2+1
            gateArray(row, col) = Id;
        end
        for col = maxNum-(row-1)*2:maxNum
            gateArray(row, col) = pulse;
        end
    end
    gateArray(end,:) = Id;% all identity gates
    gateArray(end-1,:) = Id;
    gateArray(end-1,end-1:end) = pulse; % two pulse gates

    GateMeas.qPulse = gateArray;
    % Run experiment
    GateMeas.run();
    GateMeas.plotData();

    I_data = GateMeas.data.intdataI;
    Q_data = GateMeas.data.intdataQ;

    I_2pulse = I_data(end-1);
    I_I = I_data(end);
    normalized_I = (I_data(1:end-2) - I_I)/(I_2pulse-I_I);


    Q_2pulse = Q_data(end-1);
    Q_I = Q_data(end);
    normalized_Q = (Q_data(1:end-2)-Q_I)/(Q_2pulse-Q_I);
    figure(22)
    plot(normalized_I)
    hold on 
    plot(normalized_Q)
    hold off

    amp_ratio = 0.5 *(amp_correction90(2:2:maxNum - 3,normalized_Q)...
        + amp_correction90(2:2:maxNum - 3,normalized_I));
    
    pulse.amplitude = pulse.amplitude * amp_ratio;
    
     %amp error correct pulsem
    clear('gateArray');
    maxNum = 21 +2 ; % last two gates are 2 * pi/2 and identity
    gateArray((maxNum+1)/2, maxNum) = Id;
    for row = 1:(maxNum+1)/2
        for col = 1:maxNum-row*2+1
            gateArray(row, col) = Id;
        end
        for col = maxNum-(row-1)*2:maxNum
            gateArray(row, col) = pulsem;
        end
    end
    gateArray(end,:) = Id;% all identity gates
    gateArray(end-1,:) = Id;
    gateArray(end-1,end-1:end) = pulsem; % two pulse gates

    GateMeas.qPulse = gateArray;
    % Run experiment
    GateMeas.params.trigPeriod = 20e-6;
    GateMeas.run();
    GateMeas.data.tRange = [0.5e-6, 1.5e-6];
    GateMeas.plotData();

    I_data = GateMeas.data.intdataI;
    Q_data = GateMeas.data.intdataQ;

    I_2pulse = I_data(end-1);
    I_I = I_data(end);
    normalized_I = (I_data(1:end-2) - I_I)/(I_2pulse-I_I);


    Q_2pulse = Q_data(end-1);
    Q_I = Q_data(end);
    normalized_Q = (Q_data(1:end-2)-Q_I)/(Q_2pulse-Q_I);
    figure(22)
    plot(normalized_I)
    hold on 
    plot(normalized_Q)
    hold off

    amp_ratio = 0.5 *(amp_correction90(2:2:maxNum - 3,normalized_Q)...
        + amp_correction90(2:2:maxNum - 3,normalized_I));
    
    pulsem.amplitude = pulsem.amplitude * amp_ratio;
end

