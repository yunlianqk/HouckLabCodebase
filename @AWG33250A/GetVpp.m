function vpp = GetVpp(triggen)
% Get peak to peak amplitude
    fprintf(triggen.instrhandle, 'VOLTage?');
    vpp = fscanf(triggen.instrhandle, '%f');
end
