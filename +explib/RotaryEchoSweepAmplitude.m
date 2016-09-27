%  Rotary Echo sweep amplitude

amplitudeVector = linspace(1,0,3);
durationList = logspace(log10(50e-9),log10(150e-6),51); % total delay from 1st to last pulse
softwareAverages = 20;
cardparams.averages=100;  % software averages PER SEGMENT
card.SetParams(cardparams); % Update parameters and setup acquisition and trigerring 

%initializions
display([' ']);
display(['Rotary Echo Sweep Amplitude'])
clear x
x = explib.RotaryEcho(pulseCal,durationList,amplitudeVector(1),softwareAverages);

%%

time=fix(clock);
timeString = datestr(datetime);

for ind = 1:length(amplitudeVector)
    tic;
    x = explib.RotaryEcho(pulseCal,durationList,amplitudeVector(1),softwareAverages);
    x.rabiDrive = amplitudeVector(ind);
    x.update()
    playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist); toc
    
%     loopResults.decayConstant(ind) = result.fitResults.lambda;
    loopResults.result(ind) = result;
    loopResults.amplitudeVector = amplitudeVector;
    loopResults.data(ind,:) = result.amp;
    
    
    figure(612)
    
    %     plot(amplitudeVector(1:ind),loopResults.decayConstant(1:ind));
%     imagesc(freqVector,amplitudeVector(1:ind),loopResults.Pint(1:ind,:))
    imagesc([],amplitudeVector,loopResults.data(1:ind,:))
    title(['looping ' x.experimentName ' ' timeString]);
    xlabel('amplitude')
    ylabel('decay constant')
    drawnow
    
    save(['C:\Data\RotaryEchoSweepAmplitude' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'loopResults', 'awg','card','cardparams');
    toc
end