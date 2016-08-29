function AmpVector = RFScan_Card(rfparams)

%   rfparams.freqvector - sweep the RF frequency
%   rfparams.power - RF power
%   rfparams.intfreq - LO generator frequency offset
%   rfparams.waittime - .2 s works well

global rfgen logen card triggen;

rfgen.power = rfparams.power;
rfgen.PowerOn();
rfgen.ModOff();
logen.power = 11;
logen.PowerOn();
card.params.samples = 21000;
card.params.delaytime = 1e-6;
card.params.trigPeriod = 25e-6;
triggen.frequency = 1/25e-6;

for counter = 1:length(rfparams.freqvector)
    rfgen.freq = rfparams.freqvector(counter);
    logen.freq = rfparams.freqvector(counter) + rfparams.intfreq;
    pause(rfparams.waittime);
    if counter == 1, tStart = tic; end
    [DataTrace, ~] = card.ReadIandQ();
    [AmpVector(counter), ~] = funclib.Demodulate(card.params.sampleinterval, DataTrace, rfparams.intfreq);
    
    if mod(counter,10) == 1
        figure(48);
        plot(rfparams.freqvector(1:counter)/1e9, AmpVector(1:counter));
    end
    if counter == 1
        tElapsed = toc(tStart);
        disp(['Estimated scanning time: ',num2str(tElapsed*length(rfparams.freqvector)),' seconds']);
    end
end
end

