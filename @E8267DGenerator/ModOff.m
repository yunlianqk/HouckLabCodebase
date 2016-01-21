function ModOff(gen)
% Set to CW mode
    fprintf(gen.instrhandle, 'OUTP:MODulation 0');
    fprintf(gen.instrhandle, 'PULM:STATe 0');
    fprintf(gen.instrhandle, 'WDM:STATe 0');
    fprintf(gen.instrhandle, 'POWer:ALC 1');
end