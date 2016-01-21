function ModOn(gen)
% Set to pulse mode
    fprintf(gen.instrhandle, 'OUTP:MODulation 1');
    fprintf(gen.instrhandle, 'PULM:STATe 1');
    fprintf(gen.instrhandle, 'PULM:SOURce EXT');
    fprintf(gen.instrhandle, 'WDM:STATe 1');
    fprintf(gen.instrhandle, 'POWer:ALC 0');
end