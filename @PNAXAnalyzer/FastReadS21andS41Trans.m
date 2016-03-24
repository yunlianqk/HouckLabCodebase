function [transamp, transph, S41transamp, S41transph] = FastReadS21andS41Trans(pnax,waitTime)
% reads all 4 traces out without changing unnecessary settings
    pnax.SetActiveTrace(1);
    pnax.ClearChannelAverages(pnax.transchannel);
    pause(waitTime);
    transamp=pnax.Read();
    pnax.SetActiveTrace(2);
    transph = pnax.Read();
    % read cross measurement
    pnax.SetActiveTrace(5);
    pnax.ClearChannelAverages(pnax.S41transchannel);
    pause(waitTime);
    S41transamp=pnax.Read();
    pnax.SetActiveTrace(6);
    S41transph = pnax.Read();
end
