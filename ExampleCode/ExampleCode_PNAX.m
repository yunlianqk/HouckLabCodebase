%% Add class definition files to PATH
repopath = 'F:\Documents\GitHub\HouckLabMeasurementCode\';
addpath(repopath);
clear('repopath');
%% Open PNAX 
address = 'GPIB0::16::0::INSTR'; % GPIB address for PNAX
pnax = PNAXAnalyzer(address);

%% Delete everything
pnax.DeleteAll();
%% Set channel 1 parameters for transmission S21
transCh1 = paramlib.pnax.trans();
transCh1.start = 1e9;
transCh1.stop = 13.5e9;
transCh1.points = 1001;
transCh1.power = 10;
transCh1.averages = 1000;
transCh1.ifbandwidth = 5e3;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';

pnax.SetParams(transCh1);
pnax.AvgOn();
pnax.PowerOn();
pnax.TrigContinuous();
%%

%% Set channel 2 paramters for transmission S13
transCh2 = transCh1;
transCh2.channel = 2;
transCh2.trace = 2;
transCh2.meastype = 'S13';
transCh2.format = 'UPH';

pnax.params = transCh2;

pnax.AvgOn();
pnax.TrigContinuous();

pause(3);
pnax.AutoScaleAll();
%% Hold triggers
pnax.TrigHold(1);
pnax.TrigHold(2);
%% Set channel 3 parameters for spectroscopy
specCh3 = paramlib.pnax.spec();
specCh3.channel = 3;
specCh3.trace = 4;
% Unspecified parameters will be set to default value
pnax.params = specCh3;
% Note that the trace number is NOT the "TR#" on the PNAX panel
pnax.AvgOn();
%% Set single parameter
pnax.SetActiveChannel(1);
pnax.params.start = 4e9;
pnax.TrigContinuous();

pnax.SetActiveTrace(2);
pnax.params.stop = 7e9;
pnax.TrigContinuous();

%% Read data
pnax.SetActiveTrace(transCh1.trace);
S21amp = pnax.Read();
S21freqvector = pnax.ReadAxis();

pnax.SetActiveTrace(transCh2.trace);
S13phase = pnax.Read();
S13freqvector = pnax.ReadAxis();

specamp = pnax.ReadTrace(specCh3.trace);
specfreqvector = pnax.ReadAxis();
%% Plot data
figure(1);subplot(3,1,1);
plot(S21freqvector/1e9, S21amp);
title('S21 amp trans');
subplot(3,1,2);
plot(S13freqvector/1e9, S13phase);
title('S13 phase trans');
subplot(3,1,3);
plot(specfreqvector/1e9, specamp);
title('S21 amp spec');
xlabel('Frequency (GHz)');
%% Add trace
transCh1Tr5 = TRANSParams();
transCh1Tr5.trace = 5;
transCh1Tr5.meastype = 'S11';
pnax.SetParams(transCh1Tr5);
%% Delete trace
pnax.DeleteTrace(5);
clear transCh1Tr5;

%% Close PNAX
pnax.TrigHoldAll();
pnax.PowerOff();
pnax.Finalize();