function SetTransParams(pnax, transparams)
% Perform transmission measurement

    % If channel not defined, use default channel
    if ~isfield(transparams, 'channel')
        transparams.channel = pnax.defaulttransparams.channel;
    end

    % If channel is active, get current settings
    if transparams.channel == pnax.GetActiveChannel()
        tempparams = pnax.GetParams();
    % Else, use default settings
    else
        tempparams = pnax.defaulttransparams;
    end
    
    % Fill the missing fields 
    fields = fieldnames(tempparams);
    for idx = 1:length(fields)
        if ~isfield(transparams, fields{idx})
            transparams.(fields{idx}) = tempparams.(fields{idx});
        end
    end
    
    % Check parameters
    if ~pnax.CheckParams(transparams)
        display('Parameters are not set correctly.');
        return;
    end
    % Create measurement  
    pnax.CreateMeas(transparams.channel, transparams.trace, transparams.meastype); 
    
    % Set parameters
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:TYPE LINear', ...
            transparams.channel);
    fprintf(pnax.instrhandle, 'SENse%d:FOM OFF', ...
            transparams.channel);
    fprintf(pnax.instrhandle, 'SENse%d:FOM:DISPlay:SELect ''receivers''', ...
            transparams.channel);
    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STARt %g', ...
            [transparams.channel, transparams.start]);
    fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STOP %g', ...
            [transparams.channel, transparams.stop]);
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts %g', ...
            [transparams.channel, transparams.points]);
    fprintf(pnax.instrhandle, 'SOURce%d:POWer1 %g', ...
            [transparams.channel, transparams.power]);
    fprintf(pnax.instrhandle, 'SOURce%d:POWer3:MODE AUTO', ...
            transparams.channel);
    fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth %g', ...
            [transparams.channel, transparams.ifbandwidth]);
    fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt %d', ...
            [transparams.channel, transparams.averages]);
    fprintf(pnax.instrhandle, 'CALCulate%d:FORMat %s', ...
            [transparams.channel, transparams.format]);    
end