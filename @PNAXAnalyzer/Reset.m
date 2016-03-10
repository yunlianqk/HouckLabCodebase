function Reset(pnax)
% Reset to default configuration
    for channel = pnax.GetChannelList()
        pnax.DeleteChannel(channel);
    end
    
    % Channel 1, trace 1 for trans amp
    transparams = pnax.defaulttransparams;
    transparams.channel = 1;
    transparams.trace = 1;
    transparams.format = 'MLOG';
    pnax.SetTransParams(transparams);
    % Channel 1, trace 2 for trans phase
    transparams.trace = 2;
    transparams.format = 'UPH';
    pnax.SetTransParams(transparams);
    % Channel 2, trace 3 for spec amp
    specparams = pnax.defaultspecparams;
    specparams.channel = 2;
    specparams.trace = 3;
    specparams.format = 'MLOG';
    pnax.SetSpecParams(specparams);
    % Channel 2, trace 4 for spec phase
    specparams.trace = 4;
    specparams.format = 'UPH';
    pnax.SetSpecParams(specparams);
end