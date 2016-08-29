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

Id = pulselib.singleGate('Identity');


segments = params.segments;
intdataII = nan(numIter * segments, 1);
intdataQI = nan(numIter * segments, 1);
NN = 20;
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
        intdataII(range) = mean(SingleShot.data.rawdataI{1}(:,500:1500),2);
        intdataQI(range) = mean(SingleShot.data.rawdataQ{1}(:,500:1500),2);
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

close(14)
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
%%
figure(15)
subplot(2,1,1)
hold on
histogram(intdataII)

xlabel('V_I')
legend('Identity')
hold off
subplot(2,1,2)
hold on
histogram(intdataQI)
xlabel('V_Q')
legend('Identity')
hold off
%% Integration
[NII,edgesII] = histcounts(intdataII);
[NQI,edgesQI] = histcounts(intdataQI);
[NI180,edgesI180] = histcounts(intdataI180);
[NQ180,edgesQ180] = histcounts(intdataQ180);

diff_I = 
diff_Q = 


%%
card.params.segments = 1;
card.params.averages = 30000;
[tempi, tempq] = card.ReadIandQ();figure;plot(tempi);
figure;plot(pulsegen1.timeaxis, pulsegen1.waveform1, pulsegen2.timeaxis, pulsegen2.waveform1, 'r');
card.params.delaytime
%%
