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

    if oldparams.power ~= newparams.power
        fprintf(pnax.instrhandle, 'SOURce%d:POWer3 %f', ...
                [channel, newparams.power]);
    end
    
    if oldparams.cwfreq ~= newparams.cwfreq
        fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW %f', ...
                [channel, newparams.cwfreq]);
    end
    
    if oldparams.cwpower ~= newparams.cwpower
        fprintf(pnax.instrhandle, 'SOURce%d:POWer1 %f',  ...
                [channel, newparams.cwpower]);
    end
    
    if oldparams.ifbandwidth ~= newparams.ifbandwidth
        fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth %f', ...
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