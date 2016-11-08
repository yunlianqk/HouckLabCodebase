%% pulse settings
stopTime=1000e-9;
J=10e6; % temp J
holdTime=6/J;
pulsegen.waveform1 = [(sin(2*pi*J*(0:1/pulsegen.samplingrate:holdTime))+1)./2 ...
    zeros(1,round(stopTime*pulsegen.samplingrate))];

taxisPulse = linspace(0,(length(pulsegen.waveform1)/pulsegen.samplingrate),length(pulsegen.waveform1));
pulsegen.timeaxis = taxisPulse;
pulsegen.waveform2=pulsegen.waveform1;

% Generate pulses
pulsegen.AutoMarker(); % Use this or provide your own marker
pulsegen.Generate();


%% Card Parameters

cardAcquisitionTime=holdTime+stopTime;
card.params.samples=cardAcquisitionTime/card.params.sampleinterval;
card.params.fullscale=0.5;
card.params.softAvg=3000;
card.params.trigPeriod=5e-6;
card.params.segments=1;
card.params.delaytime=140e-9;
taxisCard=linspace(0,cardAcquisitionTime,card.params.samples);

rfgen.PowerOn()
logen.PowerOn()

logen.SetPower(10)
rfgen.SetPower(10)

freqVec=linspace(5.70e9,5.95e9,50);
JVec=linspace(10e6,100e6,20);

for ldx=1:length(JVec)
    rfgen.SetPower(powVec(ldx))
    J=JVec(ldx);
    pulsegen.waveform1 = [(sin(2*pi*J*(0:1/pulsegen.samplingrate:holdTime))+1)./2 ...
        zeros(1,round(stopTime*pulsegen.samplingrate))];
    pulsegen.waveform2=pulsegen.waveform1;
    
    % Generate pulses
    pulsegen.AutoMarker(); % Use this or provide your own marker
    pulsegen.Generate();
    
    for idx=1:length(freqVec)
        if ldx==1 && idx==1
            tStart=tic;
            time=clock;
        end
        rfgen.SetFreq(freqVec(idx))
        logen.SetFreq(freqVec(idx))
        [IData(idx,:),QData(idx,:)]=card.ReadIandQ();
        IData(idx,:)=IData(idx,:)-mean(IData(idx,(length(IData)-20):end));
        QData(idx,:)=QData(idx,:)-mean(QData(idx,(length(QData)-20):end));
        
        rawFig=figure(ldx);
        subplot(2,1,1)
        imagesc(taxisCard*1e9,freqVec(1:idx)/1e9,IData(1:idx,:).^2 + QData(1:idx,:).^2);
        colorbar;
        xlabel('Time[n s]');
        ylabel('Drive Frequency [GHz]');
        title('Transmitted Power');
        subplot(2,1,2)
        plot(taxisCard*1e6,IData(idx,:).^2 + QData(idx,:).^2);
        xlabel('Time[n s]');
        pause(0.1);
        if ldx==1 && idx==1
            deltaT=toc(tStart)
            disp(['Estimated Time is '...
                num2str(length(freqVec)*length(powVec)*deltaT/3600),' hrs, or '...
                num2str(length(freqVec)*length(powVec)*deltaT/60),' min']);
            disp(['Scan should finish at ' datestr(addtodate(datenum(time),...
                round(length(freqVec)*length(powVec)*deltaT),'second'))]);
        end
    end

   
end



