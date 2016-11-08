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

%% Card Parameters

cardAcquisitionTime=45e-6;
card.params.samples=cardAcquisitionTime/card.params.sampleinterval;
card.params.fullscale=0.5;
card.params.softAvg=3500;
card.params.trigPeriod=200e-6;
card.params.segments=1;
card.params.delaytime=20e-6;
taxisCard=linspace(0,cardAcquisitionTime,card.params.samples);


rfgen.PowerOn()
logen.PowerOn()

logen.SetPower(10)

freqVec=linspace(5.7e9,6e9,200);
powVec=linspace(20,-30,25);

dailyDataDirectory='C:/Data/frequencySweepTimeDomain_081916/';
mkdir(dailyDataDirectory);

for ldx=1:length(powVec)
    rfgen.SetPower(powVec(ldx))
    for idx=1:length(freqVec)
        if ldx==1 && idx==1
            tStart=tic;
            time=clock;
        end
        rfgen.SetFreq(freqVec(idx))
        logen.SetFreq(freqVec(idx))
        [IData(idx,:),QData(idx,:)]=card.ReadIandQ();
        IData(idx,:)=IData(idx,:)-mean(IData(idx,(length(IData)-2000):end));
        QData(idx,:)=QData(idx,:)-mean(QData(idx,(length(QData)-2000):end));
        
        integratedAmp(idx,ldx)=sum(IData(idx,:).^2 + QData(idx,:).^2);
        
        rawFig=figure(4);
        imagesc(taxisCard*1e6,freqVec(1:idx)/1e9,IData(1:idx,:).^2 + QData(1:idx,:).^2);
        colorbar;
        xlabel('Time[\mu s]');
        ylabel('Drive Frequency [GHz]');
        title('Transmitted Power');
   
        if ldx==1 && idx==1
            deltaT=toc(tStart)
            disp(['Estimated Time is '...
                num2str(length(freqVec)*length(powVec)*deltaT/3600),' hrs, or '...
                num2str(length(freqVec)*length(powVec)*deltaT/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(length(freqVec)*length(powVec)*deltaT),'second'))]);
        end
    end
    filename=['frequencySweepTimeDomain_' num2str(powVec(ldx))];
    save([dailyDataDirectory filename '.mat'],...
        'IData','QData','card','pulsegen','currentVoltage','currentFlux',...
        'powVec','freqVec');
    saveas(gcf,[dailyDataDirectory filename '.png']);
    integratedAmp(:,ldx)= integratedAmp(:,ldx)./max(integratedAmp(:,ldx));
   
end

close all;


integratedFig=figure(5);
imagesc(powVec(1:ldx),freqVec/1e9,integratedAmp(:,1:ldx));
xlabel('Drive Power [dBm]');
ylabel('Drive Frequency [GHz]');
title('Integrated Power Output');
colorbar;
filename=['integratedTransmission'];
save([dailyDataDirectory filename '.mat'],...
    'card','pulsegen','currentVoltage','currentFlux',...
    'powVec','freqVec','integratedAmp');
saveas(gcf,[dailyDataDirectory filename '.png']);

% % fc.currentVoltage=[0 0 0];
% savefig('transAlongTrajectory.fig');

