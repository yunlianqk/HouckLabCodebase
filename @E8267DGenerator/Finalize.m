function Finalize(gen)
% Close instrument
    if strcmp(gen.instrhandle.Status, 'open')
%                 gen.PowerOff();
        fclose(gen.instrhandle);
    end
end