function fullResults = RBfullExperiment(pulseCal, numSequences,awg,card,cardparams)
% runs several random sequences to find gate fidelity
    
    tic; time=fix(clock);
    x=explib.RBExperimentV2(pulseCal);
    
    % preallocate for results
    fullResults.sequenceLengths = x.sequenceLengths;
    fullResults.AmpNorm = zeros(numSequences,length(x.sequenceLengths));
    fullResults.Pint = zeros(numSequences,length(x.sequenceLengths)+2);
    
    for ind=1:numSequences
        display(['RBSequence ' num2str(ind) ' running'])
        x=explib.RBExperimentV2(pulseCal);
        playlist = x.directDownloadM8195A(awg);
        result = x.directRunM8195A(awg,card,cardparams,playlist);
        toc
        fullResults.AmpNorm(ind,:)=result.AmpNorm;
        fullResults.Pint(ind,:)=result.Pint;
        figure(144)
        subplot(1,2,1)
        imagesc(fullResults.Pint(1:ind,:));
        title([x.experimentName num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6))])
        subplot(1,2,2)
        fullResults.rbFitResult = funclib.RBFit_gateIndependent2(result.xaxisNorm,fullResults.AmpNorm(1:ind,:));
        save(['C:\Data\FullRBExperiment_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
            'x', 'awg', 'cardparams', 'numSequences','fullResults');
    end