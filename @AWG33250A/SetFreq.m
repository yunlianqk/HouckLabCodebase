function SetFreq(triggen, frequency)
% Set frequency
    fprintf(triggen.instrhandle, 'FREQuency %f', frequency);
end