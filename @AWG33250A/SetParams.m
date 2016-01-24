function SetParams(triggen)
% Set parameters and generate waveform
    if (~ismember(triggen.waveform, triggen.waveoptions))
        errorstr = '';
        for counter = 1:length(triggen.waveoptions)
            errorstr = [errorstr, triggen.waveoptions{counter}, ' '];
        end
        error(['Error: waveforms can only be ', errorstr]);
    end
    commandstr = ['APPL:', triggen.waveform, ' '...
                  num2str(1/triggen.period), ' Hz, ', ...
                  num2str(triggen.vpp), ' VPP, ', ...
                  num2str(triggen.voffset), ' V'];
    fprintf(triggen.instrhandle, commandstr);
end