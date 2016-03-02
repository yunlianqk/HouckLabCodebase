function SetParams(triggen)
% Set parameters and generate waveform
    waveoptions = {'square', 'sin'};
    if (~ismember(triggen.waveform, waveoptions))
        error(['Error: waveforms can only be ', strjoin(waveoptions, ', ')]);
    end
    fprintf(triggen.instrhandle, ['APPL:', triggen.waveform, ' '...
                                  num2str(1/triggen.period), ' Hz, ', ...
                                  num2str(triggen.vpp), ' VPP, ', ...
                                  num2str(triggen.voffset), ' V']);
end