function SetWaveform(triggen, waveform)
%Set waveform
	formlist = {'SIN', 'SQUARE', 'RAMP', 'PULSE', 'NOISE', 'DC', 'USER'};
    if (~ismember(upper(waveform), formlist))
        display(['Error: waveform needs to be one of ', strjoin(formlist, ', ')]);
        return;
    else
        fprintf(triggen.instrhandle, 'FUNCtion %s', waveform);
    end

end

