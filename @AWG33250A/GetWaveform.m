function waveform = GetWaveform(triggen)
% Get waveform
    fprintf(triggen.instrhandle, 'FUNCtion?');
    waveform = fscanf(triggen.instrhandle, '%s');
end

