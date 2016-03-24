transparams.start = 5.5e9;
transparams.stop = 6.0e9;
transparams.points = 6001;
transparams.power = 0;
transparams.averages = 65536;
transparams.ifbandwidth = 10e3;
transparams.trace = 1;
transparams.meastype = 'S21';
transparams.format = 'MLOG';
pnax.transparams = transparams;
pnax.SetTransParams();
% Read S21
pause(1);
pnax.SetActiveTrace(1);
transamp = pnax.Read();
pnax.SetActiveTrace(2);
transph = pnax.Read();
% Set S41
S41transparams=transparams;
S41transparams.trace=5;
S41transparams.meastype='S41';
S41transparams.format = 'MLOG';
pnax.S41transparams = S41transparams;
pnax.SetS41TransParams();
% Read S41 
pause(1);
pnax.SetActiveTrace(5);
S41transamp = pnax.Read();
pnax.SetActiveTrace(6);
S41transph = pnax.Read();
freqvector = pnax.GetAxis();
figure(2);
subplot(2,1,1);
plot(freqvector/1e9, transamp,'b',freqvector/1e9,S41transamp,'r');
title('Amplitude - S21 red, S41 blue');
subplot(2,1,2);
plot(freqvector/1e9, transph,'b',freqvector/1e9,S41transph,'r');
title('Phase');
xlabel('Frequency (GHz)');
%% faster read
% read through measurement
waitTime=1;
pnax.SetActiveTrace(1);
pnax.ClearChannelAverages(pnax.transchannel);
pause(waitTime);
transamp=pnax.Read();
pnax.SetActiveTrace(2);
transph = pnax.Read();
% read cross measurement
pnax.SetActiveTrace(5);
pnax.ClearChannelAverages(pnax.S41transchannel);
pause(waitTime);
S41transamp=pnax.Read();
pnax.SetActiveTrace(6);
S41transph = pnax.Read();
freqvector = pnax.GetAxis();
figure();
subplot(2,1,1);
plot(freqvector/1e9, transamp,'b',freqvector/1e9,S41transamp,'r');
title('Amplitude - Through blue, Cross red');
subplot(2,1,2);
plot(freqvector/1e9, transph,'b',freqvector/1e9,S41transph,'r');
title('Phase');
xlabel('Frequency (GHz)');
%% fastest read
waitTime=1;
[transamp, transph, S41transamp, S41transph] = FastReadS21andS41Trans(waitTime);

