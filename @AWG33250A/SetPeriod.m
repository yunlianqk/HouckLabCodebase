function SetPeriod(triggen, period)
% Set period
    fprintf(triggen.instrhandle, 'FREQuency %f', 1/period);
end