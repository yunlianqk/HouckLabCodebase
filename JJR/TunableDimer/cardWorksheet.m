%% Set Up Pulse

rampTime=100e-9;
holdTime=50e-6;
blankTime=25e-6;

pulsegen.waveform1 = [linspace(0,1,round(rampTime*pulsegen.samplingrate)) ...
    ones(1,round(holdTime*pulsegen.samplingrate)) ...
    linspace(1,0,round(rampTime*pulsegen.samplingrate)) ...
    zeros(1,round(holdTime*pulsegen.samplingrate))];

taxisPulse = linspace(0,(length(pulsegen.waveform1)/pulsegen.samplingrate),length(pulsegen.waveform1));
pulsegen.timeaxis = taxisPulse;
pulsegen.waveform2=pulsegen.waveform1;


% Generate pulses
%pulsegen.AutoMarker(); % Use this or provide your own marker

pulsegen.marker1=[zeros(1,round(blankTime*pulsegen.samplingrate)) ...
    ones(1,round((holdTime+rampTime-blankTime)*pulsegen.samplingrate))];
pulsegen.marker1=[pulsegen.marker1 zeros(1,length(pulsegen.waveform1)-length(pulsegen.marker1))];
pulsegen.marker2=pulsegen.marker1;


pulsegen.Generate();

% Plot waveforms and markers
figure(1);
subplot(2,1,1);
hold off;
plot(pulsegen.timeaxis/1e-6, pulsegen.waveform1);
hold on;
plot(pulsegen.timeaxis/1e-6, pulsegen.marker1, 'r');
title('Channel 1');
legend('Waveform', 'Marker');
subplot(2,1,2);
hold off;
plot(pulsegen.timeaxis/1e-6, pulsegen.waveform2/max(abs(pulsegen.waveform2)));
hold on;
plot(pulsegen.timeaxis/1e-6, pulsegen.marker2, 'r');
xlabel('Time (\mus)');
title('Channel 2');

%%

cardAcquisitionTime=150e-6;

card.params.samples=cardAcquisitionTime/card.params.sampleinterval;
card.params.fullscale=0.5;
card.params.softAvg=20;
card.params.trigPeriod=200e-6;
card.params.segments=1;
card.params.delaytime=5e-6;
taxisCard=linspace(0,cardAcquisitionTime,card.params.samples);

[IData,QData]=card.ReadIandQ();


figure(4);
subplot(2,1,1);
plot(taxisCard*1e6,IData);
subplot(2,1,2);
plot(taxisCard*1e6,QData);

%%
figure(4);
subplot(2,1,1);
plot(IData.^2 + QData.^2);
subplot(2,1,2);
plot(atan(IData./QData));

