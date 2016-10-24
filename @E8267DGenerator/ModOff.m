function ModOff(gen)
% Set to CW mode
    fprintf(gen.instrhandle, 'PULM:STATe 0');
    if strfind(gen.Info(), 'E8267D')
        % Only E8267D has wideband I/Q modulation
        fprintf(gen.instrhandle, 'WDM:STATe 0');
    end
    fprintf(gen.instrhandle, 'POWer:ALC 1');
    fprintf(gen.instrhandle, 'OUTPut:MODulation 0');
end