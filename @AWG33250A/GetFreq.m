function frequency = GetFreq(triggen)
% Get frequency
    fprintf(triggen.instrhandle, 'FREQuency?');
    frequency = fscanf(triggen.instrhandle, '%f');
end