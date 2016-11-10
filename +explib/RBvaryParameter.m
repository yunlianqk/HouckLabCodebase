% RB varying a parameter

paramVector = 1e-9.*(4:2:20); 
numSequences = 50; % sequences per rb operation
calibRounds = 3;

time=fix(clock);
save(['C:\Data\RBVaryParameter' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
            'paramVector','numSequences','calibRounds');
for ind = 1:length(paramVector)
    % update parameter and recalibrate
    pulseCal.buffer = paramVector(ind);
    pulseCal = explib.Recalibrate(pulseCal, awg, card, cardparams,calibRounds);
    % run rb
    RBresults = explib.RBfullExperiment(pulseCal,numSequences,awg,card,cardparams);
    fidelity(ind) = RBresults.rbFitResult.avgGateFidelity;
    figure(915)
    plot(paramVector(1:ind),fidelity(1:ind))
    title('fidelity vs parameter')
    save(['C:\Data\RBVaryParameter' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
            'paramVector','numSequences','calibRounds','fidelity');
end



