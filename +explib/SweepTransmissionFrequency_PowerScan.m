% SweepTransmissionFreq_PowerScan
% script repeats sweep of transmission frequency, keeping only the
% integrated result.  plots this as a powerscan.

amplitudeVector = linspace(0,1,11);

%initializions
display([' ']);
display(['SweepTransmissionF'])
clear x
x = explib.SweepTransmissionFrequency();
cardparams.averages=10;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 
%%

time=fix(clock);
timeString = datestr(datetime);
testNum = 0;
freqVector = linspace(x.startFreq,x.stopFreq,x.points);
loopResults.Pint = zeros(length(amplitudeVector),x.points);
for ind = 1:length(amplitudeVector)
    tic;
    x = explib.SweepTransmissionFrequency();
    x.measAmplitude = amplitudeVector(ind);
    x.measurement.amplitude=x.measAmplitude;
    result = x.runExperimentM8195A(awg,card,cardparams);
    
    loopResults.Pint(ind,:) = result.Pint;
    
    figure(612)
    imagesc(freqVector,amplitudeVector(1:ind),loopResults.Pint(1:ind,:))
    title(['looping ' x.experimentName ' ' timeString]);
    xlabel('freq')
    ylabel('amplitude')
    drawnow
    
    
    toc
end
loopResults.freqVector = freqVector;
loopResults.amplitudeVector = amplitudeVector;
loopResults.experiment = x;

save(['C:\Data\SweepTransmission_PowerScan' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'loopResults', 'awg','card','cardparams');

