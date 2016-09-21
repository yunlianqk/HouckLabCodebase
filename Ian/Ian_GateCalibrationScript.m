%% Add intrument class definitions and initialize instruments
path = 'C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\';
addpath(genpath(path));
run('C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\instruments_initialize.m');
set(0,'DefaultFigureWindowStyle','docked')

%% Sync pulsegen and pulsegen2
pulsegen2.SyncWith(pulsegen1);
%% Create objects
params = measlib.QPulseMeas.Params();
instr = measlib.QPulseMeas.Instr();
GateMeas = measlib.GateCalib();
%% Set up parameters
params.driveFreq =  9.2830e+09 ;
params.drivePower = -6;
params.measFreq = 7.664e9;
params.measPower = -20;
params.intFreq = 0;
params.loPower = 11;
params.measDuration = 1e-6;
params.numAvg = 65536;
params.trigPeriod = 40e-6;
params.cardDelay = 0e-6;
% params.segments = 1;
sigma = 5e-9;
GateMeas.params = params;
%% Set up instruments
% If you name the instrument differently, change the object names accordingly
instr.qpulsegen = pulsegen1;
instr.mpulsegen = pulsegen2;
instr.rfgen = rfgen;
instr.specgen = specgen;
instr.logen = logen;
instr.digitizer = card;
instr.triggen = triggen;

GateMeas.instr = instr;

%%
Id = pulselib.singleGate('Identity');

X90 = pulselib.singleGate('X90');
X90.sigma = sigma;
X90.amplitude = 0.2;

Xm90 = pulselib.singleGate('Xm90');
Xm90.sigma = sigma;
Xm90.amplitude = 0.2;
Id = pulselib.singleGate('Identity');
% [X90,X90m] = Gate90(X90,X90m,Id ,GateMeas);
%% correct X90
clear pulse gateArray
pulse  = X90;
maxNum = 17 +2 ; % last two gates are 2 * pi/2 and identity
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
legend('I channel','Q channel')
title('Amplitude zigzag')

amp_ratio = 0.5 *(amp_correction90(2:2:maxNum - 3,normalized_Q)...
    + amp_correction90(2:2:maxNum - 3,normalized_I));

pulse.amplitude = pulse.amplitude * amp_ratio;

X90 = pulse;
% Correct Xm90
clear pulse gateArray

pulse  = Xm90;
maxNum = 17 +2 ; % last two gates are 2 * pi/2 and identity
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
legend('I channel','Q channel')
title('Amplitude zigzag')

amp_ratio = 0.5 *(amp_correction90(2:2:maxNum - 3,normalized_Q)...
    + amp_correction90(2:2:maxNum - 3,normalized_I));

pulse.amplitude = pulse.amplitude * amp_ratio;

Xm90 = pulse;


%% Test Identity and 2 pi/2
X180 = pulselib.singleGate('X180');
X180.sigma = 5e-9;
% X90.amplitude = 0.2015;

%%
% Sweep amplitude
ampplitude_ls = linspace(0.1,0.5,30);
I_data = nan(length(ampplitude_ls),1);
Q_data = nan(length(ampplitude_ls),1);

for ind  = 1:length(ampplitude_ls)
    X180.amplitude = ampplitude_ls(ind);
    clear('gateArray');
    gateArray(1,1) = X180;
    GateMeas.qPulse = gateArray;
    % Run experiment
    GateMeas.params.trigPeriod = 20e-6;

    GateMeas.run();

    GateMeas.data.tRange = [0.5e-6, 1.5e-6];
    GateMeas.plotData();
    I_data(ind) = GateMeas.data.intdataI;
    Q_data(ind) = GateMeas.data.intdataQ;
    figure(38)
    subplot(2,1,1)
    plot(ampplitude_ls, I_data)
    subplot(2,1,2)
    plot(ampplitude_ls, Q_data)
end
%%
    figure(38)
    subplot(2,1,1)
    plot(ampplitude_ls, I_data)
    xlabel('X180 amplitude')
    ylabel('V_I (V)')
    subplot(2,1,2)
    plot(ampplitude_ls, Q_data)
        xlabel('X180 amplitude')
    ylabel('V_I (V)')
%%
figure(1234)
subplot(2,1,1)
plot(GateMeas.data.intdataI)
xlabel('# of experiment')
ylabel('V_I (V)')
title(['X90 Gate Std/Mean%: ' num2str(100*std(GateMeas.data.intdataI)/mean(GateMeas.data.intdataI))])
subplot(2,1,2)
plot(GateMeas.data.intdataQ)
xlabel('# of experiment')
ylabel('V_Q (V)')
title(['X90 Gate Std/Mean%: ' num2str(100*std(GateMeas.data.intdataQ)/mean(GateMeas.data.intdataQ))])
%%
figure(1235)
subplot(2,1,1)
plot(GateMeas.data.intdataI)
xlabel('# of experiment')
ylabel('V_I (V)')
title(['X90 Gate Std/Mean%: ' num2str(100*std(GateMeas.data.intdataI)/mean(GateMeas.data.intdataI))])
subplot(2,1,2)
plot(GateMeas.data.intdataQ)
xlabel('# of experiment')
ylabel('V_Q (V)')
title(['X90 Gate Std/Mean%: ' num2str(100*std(GateMeas.data.intdataQ)/mean(GateMeas.data.intdataQ))])


%% Drag error
draglambda_ls = linspace(0,0.5,20);
I_dX90 = nan(length(draglambda_ls),1);
Q_dX90 = nan(length(draglambda_ls),1);

for i = 1:length(draglambda_ls)
    
    draglambda = draglambda_ls(i);
    X90.dragAmplitude =draglambda;
    Xm90.dragAmplitude = draglambda;
    
    clear('gateArray');
    gateArray(1,1) = X90;
    gateArray(1,2) = Xm90;
    GateMeas.qPulse = gateArray;

    GateMeas.params.trigPeriod = 25e-6;
    GateMeas.run();
    GateMeas.data.tRange = [0.5e-6, 1.5e-6];
    GateMeas.plotData();
    I_dX90(i) = GateMeas.data.intdataI;
    Q_dX90(i) = GateMeas.data.intdataQ;
    
    figure(997)
    subplot(2,1,1)
    plot(draglambda_ls,I_dX90/I_2X90)
    title('I_dX90')
    xlabel('# of experiment')
    ylabel('VI')
    subplot(2,1,2)
    plot(draglambda_ls,Q_dX90/Q_2X90)
    title('Q_dX90')
    xlabel('# of experiment')
    ylabel('VQ')
end

%%
delta_I = max(I_dX90) * 0.5;
[~, mintab_I] = peakdet(I_dX90,delta_I,draglambda_ls);
[~,ind_I]  = min(abs(mintab_I(:,1)));

delta_Q = max(Q_dX90) * 0.5;

[~, mintab_Q] = peakdet(Q_dX90,delta_Q,draglambda_ls);
[~,ind_Q]  = min(abs(mintab_Q(:,1)));
X90.dragAmplitude = 0.5 * (mintab_Q(ind_Q,1) + mintab_I(ind_I,1));

%% 2D Drag error
draglambda_ls = linspace(0.3,0.5,10);
I_dX90 = nan(length(draglambda_ls),length(draglambda_ls));
Q_dX90 = nan(length(draglambda_ls),length(draglambda_ls));

for j = 1:length(draglambda_ls)
    for i = 1:length(draglambda_ls)

        X90.dragAmplitude =draglambda_ls(i);
        Xm90.dragAmplitude = draglambda_ls(j);

        clear('gateArray');
        gateArray(1,1) = X90;
        gateArray(1,2) = Xm90;
        GateMeas.qPulse = gateArray;

        GateMeas.params.trigPeriod = 25e-6;
        GateMeas.run();
        GateMeas.data.tRange = [0.5e-6, 1.5e-6];
        GateMeas.plotData();
        I_dX90(i,j) = GateMeas.data.intdataI;
        Q_dX90(i,j) = GateMeas.data.intdataQ;

        figure(997)
        subplot(2,1,1)
        imagesc(draglambda_ls,draglambda_ls,I_dX90/I_2X90)
        title('I_dX90')
        xlabel('Drag I')
        ylabel('Drag Q')
        colorbar
        subplot(2,1,2)
        imagesc(draglambda_ls,draglambda_ls,Q_dX90/Q_2X90)
        title('Q_dX90')
        xlabel('Drag I')
        ylabel('Drag Q')
        colorbar
    end
end

%% 2D Drag correction plot
draglambda_ls = linspace(0.2,0.3,10);

figure(997)
subplot(1,2,1)
imagesc(flipud(draglambda_ls),draglambda_ls,I_dX90/I_2X90)
title('I_dX90')
xlabel('Drag X90')
ylabel('Drag Xm90')
set(gca,'Ydir','normal')
colorbar
subplot(1,2,2)
imagesc(flipud(draglambda_ls),draglambda_ls,Q_dX90/Q_2X90)
title('Q_dX90')
xlabel('Drag X90')
ylabel('Drag Xm90')
set(gca,'Ydir','normal')
colorbar

%%
X90.dragAmplitude = draglambda_ls(35);
Xm90.dragAmplitude = draglambda_ls(35);

%%
Y90 = pulselib.singleGate('Y90');
Y90.sigma = sigma;
Y90.amplitude = 0.2;

Ym90 = pulselib.singleGate('Ym90');
Ym90.sigma = sigma;
Ym90.amplitude = 0.2;
Id = pulselib.singleGate('Identity');
% [X90,X90m] = Gate90(X90,X90m,Id ,GateMeas);
% correct Y90
clear pulse gateArray
pulse  = Y90;
maxNum = 17 +2 ; % last two gates are 2 * pi/2 and identity
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
GateMeas.params.trigPeriod = 30e-6;
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
legend('I channel','Q channel')
title('Amplitude zigzag')

amp_ratio = 0.5 *(amp_correction90(2:2:maxNum - 3,normalized_Q)...
    + amp_correction90(2:2:maxNum - 3,normalized_I));

pulse.amplitude = pulse.amplitude * amp_ratio;
Y90 = pulse;
% correct Ym90
clear pulse gateArray
pulse  = Ym90;
maxNum = 17 +2 ; % last two gates are 2 * pi/2 and identity
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
legend('I channel','Q channel')
title('Amplitude zigzag')

amp_ratio = 0.5 *(amp_correction90(2:2:maxNum - 3,normalized_Q)...
    + amp_correction90(2:2:maxNum - 3,normalized_I));

pulse.amplitude = pulse.amplitude * amp_ratio;
Ym90 = pulse;

% Drag error
draglambda_ls = linspace(-1,1,10);
I_dY90 = nan(length(draglambda_ls),length(draglambda_ls));
Q_dY90 = nan(length(draglambda_ls),length(draglambda_ls));

for j = 1:length(draglambda_ls)
    for i = 1:length(draglambda_ls)

        Y90.dragAmplitude =draglambda_ls(i);
        Ym90.dragAmplitude = draglambda_ls(j);

        clear('gateArray');
        gateArray(1,1) = Y90;
        gateArray(1,2) = Ym90;
        GateMeas.qPulse = gateArray;

        GateMeas.params.trigPeriod = 25e-6;
        GateMeas.run();
        GateMeas.data.tRange = [0.5e-6, 1.5e-6];
        GateMeas.plotData();
        I_dY90(i,j) = GateMeas.data.intdataI;
        Q_dY90(i,j) = GateMeas.data.intdataQ;

        figure(99)
        subplot(2,1,1)
        imagesc(draglambda_ls,draglambda_ls,I_dY90/I_2pulse)
        title('I_dY90')
        xlabel('Drag I')
        ylabel('Drag Q')
        colorbar
        subplot(2,1,2)
        imagesc(draglambda_ls,draglambda_ls,Q_dY90/Q_2pulse)
        title('Q_dY90')
        xlabel('Drag I')
        ylabel('Drag Q')
        colorbar
    end
end

%%
figure(997)
subplot(1,2,1)
imagesc(flipud(draglambda_ls),draglambda_ls,I_dY90/I_2pulse)
title('I_dY90')
xlabel('Drag Y90')
ylabel('Drag Ym90')
set(gca,'Ydir','normal')
colorbar
subplot(1,2,2)
imagesc(flipud(draglambda_ls),draglambda_ls,Q_dY90/Q_2pulse)
title('Q_dY90')
xlabel('Drag Y90')
ylabel('Drag Ym90')
set(gca,'Ydir','normal')
colorbar
%%
Y90.dragAmplitude = -0.3878;
Ym90.dragAmplitude = -0.3878;
