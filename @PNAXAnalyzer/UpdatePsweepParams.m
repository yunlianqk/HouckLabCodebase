function UpdatePsweepParams(pnax, oldparams, newparams)
% Update power sweep parameters
    channel = pnax.GetActiveChannel();
    
    if oldparams.start ~= newparams.start
        fprintf(pnax.instrhandle, 'SOURce%d:POWer1:STARt %g',  ...
                [channel, newparams.start]);
    end

    if oldparams.stop ~= newparams.stop
        fprintf(pnax.instrhandle, 'SOURce%d:POWer1:STOP %g', ...
                [channel, newparams.stop]);
    end
    
    if oldparams.points ~= newparams.points
        fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts %g', ...
                [channel, newparams.points]);
    end
    
    if oldparams.cwfreq ~= newparams.cwfreq
        fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW %g', ...
                [channel, newparams.cwfreq]);
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