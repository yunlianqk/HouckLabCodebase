%% Add class definition files to PATH
path = 'C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\';
addpath(genpath(path));
%% Initialize instrument rack
run('C:\Users\BF1\Documents\GitHub\HouckLabMeasurementCode\instruments_initialize.m');

%% Open PNAX 
address = 16; % GPIB address for PNAX
pnax = PNAXAnalyzer(address);

%% Delete everything

pnax.DeleteAll();
%% Set channel 1 parameters
pnax.DeleteAll();
transCh1 = paramlib.pnax.trans();
transCh1.start = 0e9;
transCh1.stop = 10e9;
transCh1.points = 4000;
transCh1.power = -25;
transCh1.averages = 1000;
transCh1.ifbandwidth = 5e3;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S23';
transCh1.format = 'MLOG';

pnax.SetParams(transCh1);
pnax.AvgOn();
pnax.PowerOn;
pnax.TrigContinuous();
pause(3)
pnax.AutoScale();


%% Read data
pnax.SetActiveTrace(transCh1.trace);
S12amp = pnax.Read();
S12freq = pnax.ReadAxis();
figure();
plot(S12freq, S12amp);
xlabel('Frequency (GHz)')
ylabel('Transmission (dB)')
title('S12')
%% Power scan
power = 10:-0.05:-30;
power_len = length(power);
Amp_array = nan(power_len,10000);
for i = 1:power_len
    transCh1 = paramlib.pnax.trans();
    transCh1.start = 7e9;
    transCh1.stop = 8.2e9;
    transCh1.points = 10000;
    transCh1.power = power(i);
    transCh1.averages = 1000;
    transCh1.ifbandwidth = 5e3;
    transCh1.channel = 1;
    transCh1.trace = 1;
    transCh1.meastype = 'S13';
    transCh1.format = 'MLOG';
    
    pnax.SetParams(transCh1);
    pnax.AvgOn();
    pnax.PowerOn;
    pnax.TrigContinuous();
    pause(10)
    Amp_array(i,:) =  pnax.Read();
    Freq_array = pnax.ReadAxis();
    imagesc(Amp_array);
end

%% Setup channel 2 parameters for spectroscopy
specCh2=paramlib.pnax.spec();
% Define center and span
% fcenter=9e9;
% fspan=2e9;
% specCh2.start = fcenter-fspan/2;
% specCh2.stop = fcenter+fspan/2;
% Define start and stop
specCh2.start = 3e9;
specCh2.stop = 10e9;

specCh2.points=4001;
specCh2.power=0;
specCh2.averages=10000;
specCh2.ifbandwidth=5e3;
specCh2.cwfreq=7.668e9;
specCh2.cwpower=-20;
specCh2.channel=2;
specCh2.trace=2;
specCh2.meastype='S21';
specCh2.format='MLOG';

pnax.SetParams(specCh2);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();
%% Plot Amplitude and Phase of spec channel
pnax.SetActiveTrace(specCh2.trace);
Specfreqvector=pnax.ReadAxis();
SpecAmp=pnax.Read(); % read Amplitude data
% don't need to define separate channel/trace for phase, just change format   
pnax.params.format = 'UPH'; 
SpecPhase=pnax.Read();   % read Phase data
pnax.params.format = 'MLOG';    % back to amplitude format
figure(101);
subplot(2,1,1); plot(Specfreqvector/1e9,SpecAmp); title('Spec Amplitude')
subplot(2,1,2); plot(Specfreqvector/1e9,SpecPhase); title('Spec Phase')
%%
yoko.rampstep=0.01;
yoko.rampinterval=0.02;
SetVoltage(yoko,2.4);
%% Tunning Yoko while looking at spec channel
yoko.rampstep=0.0003;
yoko.rampinterval=0.04;
num_v = 101;
yoko_v = linspace(-1,4,num_v);
spec_amp = nan(num_v,3001);

for yoko_ind = 1:num_v
    pnax.DeleteAll();
    SetVoltage(yoko,yoko_v(yoko_ind));
    
    specCh2=paramlib.pnax.spec();
    specCh2.start = 4.7e9;
    specCh2.stop = 4.9e9;
    specCh2.points=3001;
    specCh2.power=-15;
    specCh2.averages=10000;
    specCh2.ifbandwidth=5e3;
    specCh2.cwfreq=7.668e9;
    specCh2.cwpower=-20;
    specCh2.channel=2;
    specCh2.trace=2;
    specCh2.meastype='S21';
    specCh2.format='MLOG';

    pnax.SetParams(specCh2);
    pnax.AvgOn();
    pnax.PowerOn();
    pnax.TrigContinuous();
    pause(60)
    spec_amp(yoko_ind,:) =  pnax.Read();
    Freq_array = pnax.ReadAxis();
    imagesc(spec_amp);

end
%%
figure
imagesc(Freq_array, yoko_v,spec_amp)
xlabel('Freq (Hz)')
ylabel('yoko voltage (V)')
title('Spec scan')
%%
SetVoltage(yoko,-4)


%%
yoko.rampstep=0.0004;
yoko.rampinterval=0.02;
SetVoltage(yoko,2.4);
%%

pnax.DeleteAll();
% Transmission settings
transCh1.start =6e9;
transCh1.stop = 8e9;
transCh1.points = 1001;
transCh1.power =-25;
transCh1.averages = 50000;
transCh1.ifbandwidth = 5e3;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';
scanParam.transwait=4*60;

pnax.SetParams(transCh1);
pnax.AvgOn();
pnax.PowerOn;
pnax.TrigContinuous();
pause(3)
% Spec settings
specCh2.start = 8e9;
specCh2.stop = 10e9;
specCh2.points=2001;
specCh2.power=-25;
specCh2.averages=50000;
specCh2.ifbandwidth=5e3;
specCh2.cwfreq=7.664e9;
specCh2.cwpower=-20;
specCh2.channel=2;
specCh2.trace=2;
specCh2.meastype='S21';
specCh2.format='MLOG';
scanParam.specwait=10*60;

pnax.SetParams(specCh2);
pnax.AvgOn();
pnax.PowerOn;
pnax.TrigContinuous();
pause(3)
pnax.AutoScale();
%%
pnax.SetParams(specCh2);
 %pnax.SetParams(transCh1);

amp =  pnax.Read();
freq = pnax.ReadAxis();
figure()
plot(freq,amp)

%% Spectroscopy(+Trans) vs Yoko voltage
% Transmission settings
transCh1 = paramlib.pnax.trans();
transCh1.start =7.5e9;
transCh1.stop = 7.8e9;
transCh1.points = 1001;
transCh1.power =-25;
transCh1.averages = 50000;
transCh1.ifbandwidth = 5e3;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';
scanParam.transwait= 10;

% Spec settings
specCh2 = paramlib.pnax.spec();
specCh2.start = 5e9;
specCh2.stop = 13e9;
specCh2.points=2001;
specCh2.power=-20;
specCh2.averages=50000;
specCh2.ifbandwidth=5e3;
specCh2.cwfreq=6.639e9;
specCh2.cwpower=-15;
specCh2.channel=2;
specCh2.trace=2;
specCh2.meastype='S21';
specCh2.format='MLOG';
scanParam.specwait= 30;

% scanParam.yokoVector=[-0.25,-0.24,-0.23];
scanParam.yokoVector=linspace(-4,0,31);
yoko.rampstep=0.01;
yoko.rampinterval=0.02;
[S21amp, S21freqvector,SpecAmp,SpecPhas,Specfreqvector]=Ian_SpecScan(transCh1,specCh2,pnax,yoko,scanParam);
%%
Spec_peak = Spec_peak_detect(SpecPhas,3.2);
figure(124)
imagesc(Specfreqvector/1e9,scanParam.yokoVector, Spec_peak);
xlabel('Freq (GHz)')
ylabel('Yoko (V)')
title('Peak detection')
%% Close PNAX
pnax.TrigHoldAll();
pnax.PowerOff();
pnax.Finalize();


