function ModOn(gen)
% Set to pulse mode
    fprintf(gen.instrhandle, 'OUTP:MODulation 1');
    fprintf(gen.instrhandle, 'PULM:STATe 1');
    fprintf(gen.instrhandle, 'PULM:SOURce EXT');
    if strfind(gen.Info(), 'E8267D')
        % Only E8267D has wideband I/Q modulation
        fprintf(gen.instrhandle, 'WDM:STATe 1');
    end
    fprintf(gen.instrhandle, 'POWer:ALC 0');
end