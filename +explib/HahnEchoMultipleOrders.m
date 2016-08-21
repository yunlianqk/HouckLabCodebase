% Hahn Echo multiple orders
% this script will run through various hahn echo sequences of arbitrary
% order

orderVector = 1:2:11; % these should all be odd. # of pi pulses

%initializions
time=fix(clock);
tic;
for ind = 1:length(orderVector)
    display([' ']);
    display(['Hahn Echo with ' num2str(orderVector(ind)) ' pi pulses'])
    clear x
    x = explib.HahnEchoNthOrder(pulseCal, orderVector(ind));
    playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist);
    
    
    loopResults.xaxisNorm = result.xaxisNorm;
    loopResults.pulseCal = x.pulseCal;
    loopResults.AmpNorm(ind,:) = result.AmpNorm;
    loopResults.T2Echo(ind) = result.fitResults.lambda;
    loopResults.experiment(ind) = x;
    
    figure(612)
    plot(orderVector(1:ind),loopResults.T2Echo(1:ind));
    drawnow
    
    save(['C:\Data\HahnEchoMultipleOrders' '_' num2str(time(1)) num2str(time(2)) num2str(time(3)) num2str(time(4)) num2str(time(5)) num2str(time(6)) '.mat'],...
        'loopResults', 'awg','card','cardparams');
    toc
end
