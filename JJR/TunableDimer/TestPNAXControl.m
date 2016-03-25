%% new style pnax control
transparams.start = 5.5e9;
transparams.stop = 6.0e9;
transparams.points = 6001;
transparams.power = 0;
transparams.averages = 65536;
transparams.ifbandwidth = 10e3;
% Amp trace
transparams.trace = 1;
transparams.meastype = 'S21';
transparams.format = 'MLOG';
pnax.transparams = transparams;
pnax.SetTransParams();
% Phase trace
pnax.transparams.trace = 2;
pnax.transparams.format = 'UPH';
pnax.SetTransParams();
% Read data
pause(1);
pnax.SetActiveTrace(1);
transamp = pnax.Read();
pnax.SetActiveTrace(2);
transph = pnax.Read();
freqvector = pnax.GetAxis();
figure(1);
subplot(2,1,1);
plot(freqvector/1e9, transamp);
title('Amplitude');
subplot(2,1,2);
plot(freqvector/1e9, transph);
title('Phase');
xlabel('Frequency (GHz)');


%% Spec scan with PNAX
specparams.start = 8.42e9;
specparams.stop = 8.44e9;
specparams.points = 2001;
specparams.power = -40;
specparams.averages = 65536;
specparams.ifbandwidth = 3e3;
specparams.cwfreq = 6.2558e9;
specparams.cwpower = -55;
% Amp trace
specparams.trace = 3;
specparams.meastype = 'S21';
specparams.format = 'MLOG';
pnax.specparams = specparams;
pnax.SetSpecParams();
% Phase trace
specparams.trace = 4;
specparams.format = 'UPH';
pnax.specparams = specparams;
pnax.SetSpecParams();
% Read data
pause(1);
pnax.SetActiveTrace(3);
specamp = pnax.Read();
pnax.SetActiveTrace(4);
specph = pnax.Read();
freqvector = pnax.GetAxis();
figure(2);
subplot(2,1,1);
plot(freqvector/1e9, specamp);
title('Amplitude');
subplot(2,1,2);
plot(freqvector/1e9, specph);
title('Phase');
xlabel('Spec frequency (GHz)');


%% Trying S41 
S41transparams.start = 5.5e9;
S41transparams.stop = 6.0e9;
S41transparams.points = 6001;
S41transparams.power = 0;
S41transparams.averages = 65536;
S41transparams.ifbandwidth = 10e3;
% Amp trace
S41transparams.trace = 5;
S41transparams.meastype = 'S41';
S41transparams.format = 'MLOG';
pnax.S41transparams = S41transparams;
pnax.SetS41TransParams();
% Phase trace
pnax.S41transparams.trace = 6;
pnax.S41transparams.format = 'UPH';
pnax.SetS41TransParams();
% Read data
pause(1);
pnax.SetActiveTrace(5);
S41transamp = pnax.Read();
pnax.SetActiveTrace(6);
S41transph = pnax.Read();
freqvector = pnax.GetAxis();
figure(1);
subplot(2,1,1);
plot(freqvector/1e9, S41transamp);
title('Amplitude');
subplot(2,1,2);
plot(freqvector/1e9, transph);
title('Phase');
xlabel('Frequency (GHz)');
%% S41Spec scan with PNAX
S41specparams.start = 8.42e9;
S41specparams.stop = 8.44e9;
S41specparams.points = 2001;
S41specparams.power = -40;
S41specparams.averages = 65536;
S41specparams.ifbandwidth = 3e3;
S41specparams.cwfreq = 6.2558e9;
S41specparams.cwpower = -55;
% Amp trace
S41specparams.trace = 7;
S41specparams.meastype = 'S41';
S41specparams.format = 'MLOG';
pnax.S41specparams = S41specparams;
pnax.SetS41SpecParams();
% Phase trace
S41specparams.trace = 8;
S41specparams.format = 'UPH';
pnax.S41specparams = S41specparams;
pnax.SetS41SpecParams();
% Read data
pause(1);
pnax.SetActiveTrace(7);
S41specamp = pnax.Read();
pnax.SetActiveTrace(8);
S41specph = pnax.Read();
freqvector = pnax.GetAxis();
figure(2);
subplot(2,1,1);
plot(freqvector/1e9, S41specamp);
title('Amplitude');
subplot(2,1,2);
plot(freqvector/1e9, S41specph);
title('Phase');
xlabel('Spec frequency (GHz)');




