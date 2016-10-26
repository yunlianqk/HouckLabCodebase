function offset = GetOffset(triggen)
% Get voltage offset
    fprintf(triggen.instrhandle, 'VOLTage:OFFSet?');
    offset = fscanf(triggen.instrhandle, '%f');
end