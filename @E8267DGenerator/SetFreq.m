function SetFreq(gen, freq)
% Set frequency
    fprintf(gen.instrhandle, 'FREQuency %f', freq);
end