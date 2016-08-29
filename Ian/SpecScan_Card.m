function [ AmpVector, PhaseVector ] = SpecScan_Card(rfparams, specparams)

%   rfparams.freq - holds the RF tone at a constant frequency
%   rfparams.power - RF power
%   rfparams.intfreq - LO generator frequency offset
%   rfparams.waittime - .2 s works well
%   specparams.power - spec generator power
%   specparams.freqvector - values of frequency sweep on specgen

global rfgen specgen logen card triggen;

specgen.power = specparams.power;
specgen.ModOff();
rfgen.freq = rfparams.freq;
rfgen.power = rfparams.power;
rfgen.PowerOn();
rfgen.ModOff();
logen.freq = rfparams.freq + rfparams.intfreq;
logen.power = 11;
logen.PowerOn();
card.params.samples = 21000;
card.params.delaytime = 1e-6;
card.params.trigPeriod = 25e-6;
triggen.frequency = 1/25e-6;

for counter = 1:length(specparams.freqvector)
    if counter == 1, tStart = tic; end
    specgen.freq = specparams.freqvector(counter);
    specgen.PowerOn();
    pause(rfparams.waittime);
    [DataTrace, ~] = card.ReadIandQ();
    [OnAmp, OnPhase] = funclib.Demodulate(card.params.sampleinterval, DataTrace, rfparams.intfreq);
    
    specgen.PowerOff();
    pause(rfparams.waittime);
    [DataTrace, ~] = card.ReadIandQ();
    [OffAmp,OffPhase] = funclib.Demodulate(card.params.sampleinterval, DataTrace, rfparams.intfreq);
    AmpVector(counter) = OnAmp/OffAmp;
    PhaseVector(counter) = OnPhase-OffPhase;
    
    if mod(counter,10) == 1
        figure(47);
        subplot(2,1,1); plot(specparams.freqvector(1:counter)/1e9, AmpVector);title('Amp')
        subplot(2,1,2); plot(specparams.freqvector(1:counter)/1e9, PhaseVector);title('Phase')
    end
    if counter == 1
        tElapsed = toc(tStart);
        disp(['Estimated scanning time: ',num2str(tElapsed*length(specparams.freqvector)),' seconds']);
    end
end
end

