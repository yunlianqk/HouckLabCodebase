function Finalize(yoko)
% Close instrhandle
    if strcmp(yoko.instrhandle.Status, 'open')
        fclose(yoko.instrhandle);
    end
end