function Finalize(triggen)
% Close instrhandle
    if strcmp(triggen.instrhandle.Status, 'open')
        fclose(triggen.instrhandle);
    end
end