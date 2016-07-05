function SetVpp(triggen, vpp)
% Set peak to peak amplitude
    fprintf(triggen.instrhandle, 'VOLTage %f', vpp);
end
