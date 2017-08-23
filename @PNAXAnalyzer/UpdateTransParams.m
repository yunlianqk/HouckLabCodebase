function UpdateTransParams(pnax, oldparams, newparams)
% Update transmission parameters
    channel = pnax.GetActiveChannel();

    if oldparams.start ~= newparams.start
        fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STARt %f', ...
                [channel, newparams.start]);
    end

    if oldparams.stop ~= newparams.stop
        fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STOP %f', ...
                [channel, newparams.stop]);
    end            

    if oldparams.points ~= newparams.points
        fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts %d', ...
                [channel, newparams.points]);
    end            

    if oldparams.power ~= newparams.power
        fprintf(pnax.instrhandle, sprintf('SOURce%d:POWer%s %f', ...
                                          channel, ...
                                          newparams.meastype(end), ...
                                          newparams.power));
    end

    if oldparams.ifbandwidth ~= newparams.ifbandwidth
        fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth %f', ...
                [channel, newparams.ifbandwidth]);
    end

    if oldparams.averages ~= newparams.averages
        fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt %d', ...
                [channel, newparams.averages]);
    end

    if ~strcmpi(oldparams.avgmode, newparams.avgmode)
        fprintf(pnax.instrhandle, 'SENSe%d:AVERage:MODE %s', ...
                [channel, newparams.avgmode]);
    end

    if ~strcmpi(oldparams.format, newparams.format)
        fprintf(pnax.instrhandle, 'CALCulate%d:FORMat %s', ...
                [channel, newparams.format]);
    end

end