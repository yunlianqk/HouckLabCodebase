function SetPeriod(triggen, period)
% Set period
    fprintf(triggen.instrhandle,['APPL:SQUARE ', num2str(1/period), ...
                                 ' HZ, 2.0 VPP, 1.0 V']);
end