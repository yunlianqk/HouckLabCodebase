%% Add class definition files to PATH
path = 'C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\';
addpath(genpath(path));
%% Initialize instrument rack
% Optional if you only need to use the pnax
run('C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\instruments_initialize.m');
%% Sync pulsegen and pulsegen2
pulsegen2.SyncWith(pulsegen1);
%% Start AWG
pulsegen1.Generate();
%%
yoko.rampstep=0.01;
yoko.rampinterval=0.02;
SetVoltage(yoko,-1.3);
%% Spec scan with generators and digitizer
rfparams.power = -55;
rfparams.freq = 7.664e9;
rfparams.intfreq = 2e6;
rfparams.waittime = 0.2;
specparams.power = -35;
specparams.freqvector = linspace(7.12e9, 7.15e9, 61);

card.params.samples = 21000;
card.params.delaytime = 1e-6;
card.params.trigPeriod = 25e-6;
card.params.averages = 40000;

triggen.frequency = 1/card.params.trigPeriod;
%%
[amp, phase] = SpecScan_Card(rfparams, specparams);

%% Spec scan with pulse readout
specgen.power = specparams.power;
specgen.ModOff();
rfgen.freq = rfparams.freq;
rfgen.power = rfparams.power;
rfgen.PowerOn();
rfgen.ModOn();
logen.freq = rfparams.freq + rfparams.intfreq;
logen.power = 11;
logen.PowerOn();

card.params.samples = 7008;
card.params.delaytime = 5e-6;
card.params.trigPeriod = 25e-6;
card.params.averages = 60000;
tDigitizer = (0:card.params.samples-1)*card.params.sampleinterval;

for counter = 1:length(specparams.freqvector)
    
    if counter == 1, tStart = tic; end
    specgen.freq = specparams.freqvector(counter);
    specgen.PowerOn();
    pause(rfparams.WaitTime);
    [Ondatai, Ondataq] = card.ReadIandQ();
    specgen.PowerOff();
    pause(rfparams.waittime);
    [Offdatai, Offdataq] = card.ReadIandQ();
    rawdataI(counter, :) = Ondatai - Offdatai;
    rawdataQ(counter, :) = Ondataq - Offdataq;
    
    if mod(counter,10) == 1
        figure(47);
        subplot(2,1,1);
        imagesc(tDigitizer/1e-6, specparams.freqvector(1:counter), rawdataI(1:counter,:));
        subplot(2,1,2);
        imagesc(tDigitizer/1e-6, specparams.freqvector(1:counter), rawdataQ(1:counter,:));
    end
    
    if counter == 1
        tElapsed = toc(tStart);
        disp(['Estimated scanning time: ',num2str(tElapsed*length(specparams.freqvector)),' seconds']);
    end
end

%% RF scan by pulse gen
rfparams.freqvector = linspace(7.4e9, 8.4e9, 101);
rfparams.power = -35;
rfparams.intfreq = 2e6;
rfparams.waittime = 0.2;
card.params.averages = 60000;%card average
ampvector = RFScan_Card(rfparams);

%% Spec scan by pulse gen
rfparams.power = -35;
rfparams.freq = 7.664e9;
rfparams.intfreq = 2e6;
rfparams.waittime = 0.2;
specparams.power = -15;
specparams.freqvector = linspace(9.2e9, 9.35e9, 51);
card.params.averages = 60000;%card average
[amp, phase] = SpecScan_Card(rfparams, specparams);

