function period = GetPeriod(triggen)
% Get period
    fprintf(triggen.instrhandle, 'FREQuency?');
    period = 1/fscanf(triggen.instrhandle, '%f');
end