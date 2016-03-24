function SetSpecParams(pnax, specparams)
% Perform spectroscopy measurement

    % If channel not defined, use default channel
    if ~isfield(specparams, 'channel')
        specparams.channel = pnax.defaultspecparams.channel;
    end

    % If channel is active, get current settings
    if specparams.channel == pnax.GetActiveChannel()
        tempparams = pnax.GetParams();
    % Else, use default settings
    else
        tempparams = pnax.defaultspecparams;
    end
    
    % Fill the missing fields 
    fields = fieldnames(tempparams);
    for idx = 1:length(fields)
        if ~isfield(specparams, fields{idx})
            specparams.(fields{idx}) = tempparams.(fields{idx});
        end
    end
    
    % Check parameters
    if ~pnax.CheckParams(specparams)
        display('Parameters are not set correctly.');
        return;
    end
    % Create measurement  
    pnax.CreateMeas(specparams.channel, specparams.trace, specparams.meastype);
    
    % Set parameters
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:TYPE CW', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENSe%d:FOM:RANGe4:COUPled OFF', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENSe%d:FOM:RANGe4:SWEep:TYPE LINear', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENse%d:FOM ON', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENse%d:FOM:DISPlay:SELect ''source2''', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STARt %g', ...
            [specparams.channel, specparams.start]);
    fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STOP %g', ...
            [specparams.channel, specparams.stop]);
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts %d', ...
            [specparams.channel, specparams.points]);
    fprintf(pnax.instrhandle, 'SOURce%d:POWer:COUPle OFF', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'SOURce%d:POWer3 %g', ...
            [specparams.channel, specparams.power]);
    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt %d', ...
            [specparams.channel, specparams.averages]);
    fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth %g', ...
            [specparams.channel, specparams.ifbandwidth]);
    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW %g', ...
            [specparams.channel, specparams.cwfreq]);
    fprintf(pnax.instrhandle, 'SOURce%d:POWer1 %g',  ...
            [specparams.channel, specparams.cwpower]);
    fprintf(pnax.instrhandle, 'SOURce%d:POWer3:MODE ON', ...
            specparams.channel);
    fprintf(pnax.instrhandle, 'CALCulate%d:FORMat %s', ...
            [specparams.channel, specparams.format]);
end