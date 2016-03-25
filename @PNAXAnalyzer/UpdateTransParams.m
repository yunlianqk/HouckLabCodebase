function UpdateTransParams(pnax, oldparams, newparams)
% Update transmission parameters
    channel = pnax.GetActiveChannel();

    if oldparams.start ~= newparams.start
        fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STARt %g', ...
                [channel, newparams.start]);
    end

    if oldparams.stop ~= newparams.stop
        fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STOP %g', ...
                [channel, newparams.stop]);
    end            

    if oldparams.points ~= newparams.points
        fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts %g', ...
                [channel, newparams.points]);
    end            

    if oldparams.power ~= newparams.power
        fprintf(pnax.instrhandle, 'SOURce%d:POWer1 %g', ...
                [channel, newparams.power]);
    end

    if oldparams.ifbandwidth ~= newparams.ifbandwidth
        fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth %g', ...
                [channel, newparams.ifbandwidth]);
    end

    if oldparams.averages ~= newparams.averages
        fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt %d', ...
                [channel, newparams.averages]);
    end

    if ~strcmp(oldparams.format, newparams.format)
        fprintf(pnax.instrhandle, 'CALCulate%d:FORMat %s', ...
                [channel, newparams.format]);
    end

end