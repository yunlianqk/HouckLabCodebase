function Finalize(pnax)
% Close instrument
    if strcmp(pnax.instrhandle.Status, 'open')
        fprintf(pnax.instrhandle, 'SYSTem:CHANnels:HOLD');
        fclose(pnax.instrhandle);
    end
end