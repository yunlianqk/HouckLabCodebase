for freqInd = 2:12
    display(' ')
    display(['t2 spec experiment # ' num2str(freqInd)])
    specVector = linspace(freqInd*1e9,(freqInd+1)*1e9,101);
    clear x
    x = explib.T2Spectroscopy(pulseCal,specVector);
    tic; playlist = x.directDownloadM8195A(awg); toc
    tic; time=fix(clock);
    result = x.directRunM8195A(awg,card,cardparams,playlist); toc
    save(['C:\Data\' x.experimentName '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'x', 'awg', 'cardparams', 'result');
end
