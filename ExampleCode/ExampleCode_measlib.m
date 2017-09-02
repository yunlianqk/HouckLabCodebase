% Example code for single qubit CW and pulsed measurements
% using E8267D generators, M9330 AWG and U1082A/U1084A digitizer
%% Check instruments
% rfgen, specgen, logen, triggen, pulsegen1, pulsegen2, card
% need to be initialized before using this script.
success = 1;
for instr = {'rfgen', 'specgen', 'logen', 'triggen', ...
             'pulsegen1', 'pulsegen2', 'card'}
    try
        eval(['s = ', instr{1}, '.Info();']);
    catch
        display(['Error: Cannot find ', instr{1}]);
        success = 0;
    end
end

if success
    disp('Instrument all initialized.');
else
    error('Missing instruments.');
end

clear instr s success;
%% Pulse parameters are defined in pulseCal
pulseCal = paramlib.pulseCal();
pulseCal.qubitFreq = 3.536e9;
pulseCal.specPower = 5;
pulseCal.sigma = 200e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.buffer = 10e-9;
pulseCal.cavityFreq = 4.0449e9;
pulseCal.rfPower = -50;
pulseCal.intFreq = 5e6;
pulseCal.loPower = 12;
pulseCal.measDuration = 5e-6;
pulseCal.cavityAmplitude = 1;
pulseCal.samplingRate = pulsegen1.samplingrate;
pulseCal.X180Amplitude = 1;
pulseCal.X90Amplitude = pulseCal.X180Amplitude / 2;
pulseCal.Xm90Amplitude = pulseCal.X180Amplitude / 2;
pulseCal.Y180Amplitude = pulseCal.X180Amplitude;
pulseCal.Y90Amplitude = pulseCal.X180Amplitude / 2;
pulseCal.Ym90Amplitude = pulseCal.X180Amplitude / 2;
%% Common configurations are stored in config
config.cardacqtime = pulseCal.measDuration;
config.cardavg = 65536;
config.carddelayoffset = 0.5e-6;
config.waittime = 0.2;
config.plotsweep1 = 0;
config.plotsweep2 = 1;
config.plotupdate = 10;
config.normalization = 0;
config.autosave = 0;
config.savepath = 'D:\Users\temp\';
%% Transmission sweep, CW mode
x = measlib.TransSweep(config);
x.rffreq = linspace(8e9, 8.1e9, 101);
x.rfpower = -45;
x.intfreq = 2e6;
x.lopower = 11;
x.bgsubtraction = 'rfonoff';
x.SetUp();
tic;
x.Run();
toc;
x.Plot();
%% Transmission sweep, pulse mode
x = measlib.TransSweep(config);
x.rffreq = linspace(8e9, 8.1e9, 101);
x.rfpower = -45;
x.intfreq = 2e6;
x.lopower = 11;
x.pulseCal = pulseCal;
x.qubitGates = 'X180';
x.bgsubtraction = 'rfonoff';
x.SetUp();
tic;
x.Run();
toc;
x.Plot();
%% Spec sweep, CW mode
x = measlib.SpecSweep(config);
x.rffreq = 8.05e9;
x.rfpower = -40;
x.intfreq = 2e6;
x.lopower = 11;
x.specfreq = linspace(5.2e9, 5.3e9, 101);
x.specpower = -30;
x.bgsubtraction = 'speconoff';
x.SetUp();
tic;
x.Run();
toc;
x.Plot();
%% Spec sweep, pulse mode
x = measlib.SpecSweep(config);
x.rffreq = 8.05e9;
x.rfpower = -40;
x.intfreq = 2e6;
x.lopower = 11;
x.specfreq = linspace(5.2e9, 5.3e9, 101);
x.specpower = 5;
x.pulseCal = pulseCal;
x.qubitGates = 'X180';
x.bgsubtraction = 'speconoff';
x.SetUp();
tic;
x.Run();
toc;
x.Plot();
%% Rabi
x = measlib.Rabi(pulseCal, config);
x.qubitGates = {'X180'};
x.ampVector = linspace(0, 1, 101);
x.trigperiod = 17e-6;
x.bgsubtraction = 'speconoff';
x.SetUp();
tic;
x.Run();
toc;
x.Fit();
%% T1
x = measlib.T1(pulseCal, config);
x.qubitGates = {'X180'};
x.delayVector = linspace(0, 40e-6, 101);
x.trigperiod = 62.5e-6;
x.SetUp();
tic;
x.Run();
toc;
x.Fit();
%% Ramsey
x = measlib.Ramsey(pulseCal, config);
x.qubitGates = {'X90'};
x.delayVector = linspace(0, 5e-6, 101);
x.pulseCal.qubitFreq = x.pulseCal.qubitFreq - 2e6;
x.trigperiod = 30e-6;
x.SetUp();
tic;
x.Run();
toc;
x.Fit();
%% Echo
x = measlib.Echo(pulseCal, config);
x.qubitGates = {'X90'};
x.echoGates = {'X180'};
x.delayVector = linspace(0, 10e-6, 101);
x.numfringes = 7.5;
x.trigperiod = 30e-6;
x.SetUp();
tic;
x.Run();
toc;
x.Fit();
%% Save data
x.Save();
%% Load data
cd(x.savepath);
filename = x.savefile;
x = measlib.SmartSweep.Load(filename);
x.Plot();