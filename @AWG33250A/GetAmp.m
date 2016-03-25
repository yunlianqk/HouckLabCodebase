function vpp = GetAmp(triggen)
% Get peak to peak amplitude
    fprintf(triggen.instrhandle, 'VOLTage?');
    vpp = fscanf(triggen.instrhandle, '%g');
end