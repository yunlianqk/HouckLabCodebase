pulsegen2.Finalize
pulsegen1.Finalize
card.Finalize
%% Add intrument class definitions and initialize instruments
path = 'C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\';
addpath(genpath(path));
run('C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\instruments_initialize.m');
set(0,'DefaultFigureWindowStyle','docked')

%% Sync pulsegen and pulsegen2

pulsegen2.SyncWith(pulsegen1);
%%
card.params.fullscale = 0.5;
%% Create objects
params = measlib.SingleShot.Params();
instr = measlib.SingleShot.Instr();
SingleShot = measlib.GateSingleShot();
%% Set up parameters
params.driveFreq = 9.2830e+09;
params.drivePower = -6;
params.measFreq = 7.664e9;
params.measPower = -20;
params.intFreq = 0;
params.loPower = 11;
params.measDuration = 1e-6;
params.numAvg = 1;% 65536 * 5;
params.trigPeriod = 25e-6;
params.cardDelay = 0e-6;
params.segments = 1000;
SingleShot.params = params;

%% Set up instruments
% If you name the instrument differently, change the object names accordingly
instr.qpulsegen = pulsegen1;
instr.mpulsegen = pulsegen2;
instr.rfgen = rfgen;
instr.specgen = specgen;
instr.logen = logen;
instr.digitizer = card;
instr.triggen = triggen;

SingleShot.instr = instr;

%% Histogram of Identity and X180
SingleShot.params.measFreq = 7.76e9;
SingleShot.params.measPower = -20;

Id = pulselib.singleGate('Identity');

NN = 20;

segments = params.segments;
intdataII = nan(NN * segments, 1);
intdataQI = nan(NN * segments, 1);

for numIter = 1:NN
    if numIter == 1
        tic;
        clear('gateArray');
        gateArray(1,1) = Id;
        SingleShot.qPulse = gateArray;
        % Run experiment
        SingleShot.params.trigPeriod = 25e-6;
        SingleShot.run();
        [numSteps,~] = size(gateArray);
        range = ((numIter - 1) * segments + 1 : numIter * segments);
        intdataII(range) = mean(SingleShot.data.rawdataI{1}(:,500:600),2);
        intdataQI(range) = mean(SingleShot.data.rawdataQ{1}(:,500:600),2);
        ['Estimated wait time: ' num2str(toc * NN * 2/60) ' mins']
    else
        clear('gateArray');
        gateArray(1,1) = Id;
        SingleShot.qPulse = gateArray;
        % Run experiment
        SingleShot.params.trigPeriod = 25e-6;
        SingleShot.run();
        [numSteps,~] = size(gateArray);
        range = ((numIter - 1) * segments + 1 : numIter * segments);
        intdataII(range) = mean(SingleShot.data.rawdataI{1}(:,500:600),2);
        intdataQI(range) = mean(SingleShot.data.rawdataQ{1}(:,500:600),2);
    end

end

X180 = pulselib.singleGate('X180');
X180.sigma = 5e-9;
X180.amplitude = 0.403;


segments = params.segments;
intdataI180 = nan(numIter * segments, 1);
intdataQ180 = nan(numIter * segments, 1);

for numIter = 1:NN
    clear('gateArray');
    gateArray(1,1) = X180;
    SingleShot.qPulse = gateArray;
    % Run experiment
    SingleShot.params.trigPeriod = 25e-6;
    SingleShot.run();
    [numSteps,~] = size(gateArray);
    range = ((numIter - 1) * segments + 1 : numIter * segments);
    intdataI180(range) = mean(SingleShot.data.rawdataI{1}(:,500:600),2);
    intdataQ180(range) = mean(SingleShot.data.rawdataQ{1}(:,500:600),2);

end
warndlg('Finished','...')
figure(14)
subplot(2,1,1)
hold on
histogram(intdataI180)
histogram(intdataII)
xlabel('V_I')
legend('Identity', 'X180')
hold off
subplot(2,1,2)
hold on
histogram(intdataQ180)
histogram(intdataQI)
xlabel('V_Q')
legend('Identity', 'X180')
hold off

% S curve
totN = NN * segments;

lower_boundII = min(intdataII);
lower_boundI180 = min(intdataI180);
upper_boundII = max(intdataII);
upper_boundI180 = max(intdataI180);

lower_boundI = min(lower_boundII,lower_boundI180);
upper_boundI = max(upper_boundII,upper_boundI180 );

diff = upper_boundI - lower_boundI ;
edgeI = lower_boundI: 0.01 * diff: upper_boundI;

NII = histcounts(intdataII,edgeI);
NQI = histcounts(intdataQI,edgeI);



lower_boundQI = min(intdataQI);
lower_boundQ180 = min(intdataQ180);
upper_boundQI = max(intdataQI);
upper_boundQ180 = max(intdataQ180);

lower_boundQ = min(lower_boundQI,lower_boundQ180);
upper_boundQ = max(upper_boundQI,upper_boundQ180 );

diff = upper_boundQ - lower_boundQ;
edgeQ = lower_boundQ: 0.01 * diff: upper_boundQ;

NI180 = histcounts(intdataI180,edgeQ);
NQ180 = histcounts(intdataQ180,edgeQ);

%
figure(231)
plot(edgeI(2:end),cumsum(NII)/totN) 
hold on 
plot(edgeI(2:end),cumsum(NI180)/totN) 
title('S curve for I channel')

figure(232)
plot(edgeQ(2:end),cumsum(NII)/totN) 
hold on 
plot(edgeQ(2:end),cumsum(NI180)/totN) 
title('S curve for Q channel')
%
readout_fid_I = max(abs(cumsum(NII) - cumsum(NI180)))/totN
readout_fid_Q = max(abs(cumsum(NQI) - cumsum(NQ180)))/totN
    
%%
[III,QQQ] = Readout_fid( SingleShot, Id, X180)
    
%%
card.params.segments = 1;
card.params.averages = 30000;
[tempi, tempq] = card.ReadIandQ();figure;plot(tempi);
figure;plot(pulsegen1.timeaxis, pulsegen1.waveform1, pulsegen2.timeaxis, pulsegen2.waveform1, 'r');
card.params.delaytime
%%
freq_ls = linspace(7.5e9,8.0e9,30);
amp_ls = linspace(-30,30,30);
readout_fid_I = nan(length(freq_ls),length(amp_ls));
readout_fid_Q = nan(length(freq_ls),length(amp_ls));
NN_run = length(freq_ls)*length(amp_ls);
count = 1;
h = waitbar(0,'Please wait...');
for freq_ind = 1:length(freq_ls)
    for amp_ind = 1:length(amp_ls)
        tic
        try
            SingleShot.params.measFreq = freq_ls(freq_ind);
            SingleShot.params.measPower = amp_ls(amp_ind);
            [tempI,tempQ ] = Readout_fid(SingleShot, Id, X180 );
            readout_fid_I(freq_ind, amp_ind) = tempI;     
            readout_fid_Q(freq_ind, amp_ind) = tempQ;
            clims = [0 1];
            figure(212)
            subplot(2,1,1)
            imagesc(freq_ls/1e9,amp_ls,readout_fid_I, clims)
            xlabel('Readout frequency (GHz)')
            ylabel('Readout power(dBm)')
            title('Measurement fidelity I')
            colorbar
            subplot(2,1,2)
            imagesc(freq_ls,amp_ls,readout_fid_Q, clims)
            colorbar
            xlabel('Readout frequency (GHz)')
            ylabel('Readout power(dBm)')
            title('Measurement fidelity I')
        end
        toc
        message = ['Estimate finish time in: ' num2str(toc * NN_run/60), ' mins'];
        waitbar(count/NN_run,h,sprintf(message))
        count = count+1;
       
    end
end
