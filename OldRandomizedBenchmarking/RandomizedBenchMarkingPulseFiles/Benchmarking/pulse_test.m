% function my_pulse = pulse_test()
%   delay = 0;
% fixedPt = 1500;
% cycleLen = 5500;
% pg = PatternGen('dPiAmp',80,'dPiOn2Amp',40,'cycleLength', cycleLen);
% echotimes = 200;
% patseq = {pg.pulse('X90p'),...
% 			pg.pulse('QId', 'width', echotimes),...
% 			pg.pulse('Yp'), ...
% 			pg.pulse('QId', 'width', echotimes),...
% 			pg.pulse('X90m')};
% [patx paty] = pg.getPatternSeq(patseq, 1, delay, fixedPt);
% ch1 = patx;
% ch2 = paty;
% ch1m1 = pg.bufferPulse(patx, paty, 0, 50, 10, 25);
% measLength = 500;
% measSeq = {pg.pulse('M', 'width',measLength)};
% ch2m1 = pg.getPatternSeq(measSeq, 1, 0,1500+measLength);
% ch2m2 = pg.makePattern([],500, ones(100,1),cycleLen);
% plot(ch1);
% hold on;
% plot(ch2,'r');
% hold on;
% plot(50*ch1m1,'g-.');
% hold on;
% plot(50*ch2m1,'y.');
% hold on;
% plot(50*ch2m2,'mx');
% end


function [] = Rabi_oscillaton()

clear classes;
clear patseq pg patx paty patx_marker measSeq meas_marker 

delay = 0;
fixedPt = 500;
measLength = 2000;
cycleLen = 3000;
sigma = 10;
pulseLength = 4*sigma;
pg = PatternGen('dPiAmp', 80, 'dSigma', sigma, 'dPulseLength', pulseLength,'cycleLength', cycleLen);

% Gaussian excitation pulse
patSeq = {pg.pulse('Xp')};
[patx paty] = pg.getPatternSeq(patSeq, 1, delay, fixedPt);

%bufferPulse(patx,paty,zerolevel,padding,reset,delay)
patx_marker = pg.bufferPulse(patx, paty, 0, pulseLength, 0, 10);%set window for the pulse
trigger = pg.makePattern([], 100, ones(100,1), cycleLen);
patx_marker(1:cycleLen) = [trigger(1:200);2*patx_marker(201:cycleLen)];


measSeq = {pg.pulse('M', 'width', measLength)};
meas_marker = pg.getPatternSeq(measSeq, 1, 0, fixedPt+measLength);%measurement pulse

plot(patx);hold on;plot(patx_marker,'r');hold on;plot(meas_marker*10,'-.');%hold on;plot(trigger,'m')
