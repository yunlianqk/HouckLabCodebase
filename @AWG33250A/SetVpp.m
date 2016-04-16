function SetVpp(triggen, vpp)
% Set peak to peak amplitude
    fprintf(triggen.instrhandle, 'VOLTage %g', vpp);
end
