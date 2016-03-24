function SetOffset(triggen, offset)
% Set voltage offset
    fprintf(triggen.instrhandle, 'VOLTage:OFFSet %g', offset);
end