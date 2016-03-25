function SetFreq(triggen, frequency)
% Set frequency
    fprintf(triggen.instrhandle, 'FREQuency %g', frequency);
end