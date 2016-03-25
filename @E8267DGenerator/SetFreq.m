function SetFreq(gen, freq)
% Set frequency
    fprintf(gen.instrhandle, 'FREQuency %g', freq);
end