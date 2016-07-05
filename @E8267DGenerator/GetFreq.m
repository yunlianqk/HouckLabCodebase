function freq = GetFreq(gen)
% Get frequency
    fprintf(gen.instrhandle, 'FREQuency?');
    freq = fscanf(gen.instrhandle, '%f');
end