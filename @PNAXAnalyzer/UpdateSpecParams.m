function UpdateSpecParams(pnax, oldparams, newparams)
% Update spectroscopy parameters
    channel = pnax.GetActiveChannel();

    if oldparams.start ~= newparams.start
        fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STARt %f',  ...
                [channel, newparams.start]);
    end

    if oldparams.stop ~= newparams.stop
        fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STOP %f', ...
                [channel, newparams.stop]);
    end            

    if oldparams.points ~= newparams.points
        fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts %d', ...
                [channel, newparams.points]);
    end            

    if oldparams.specpower ~= newparams.specpower
        fprintf(pnax.instrhandle, 'SOURce%d:POWer3 %f', ...
                [channel, newparams.specpower]);
    end

    if oldparams.cwfreq ~= newparams.cwfreq
        fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW %f', ...
                [channel, newparams.cwfreq]);
    end

    if oldparams.cwpower ~= newparams.cwpower
        fprintf(pnax.instrhandle, sprintf('SOURce%d:POWer%s %f',  ...
                                          channel, ...
                                          newparams.meastype(end), ...
                                          newparams.cwpower));
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