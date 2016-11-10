function stop = GetStopFreq(pxa)
% Get stop frequency
    fprintf(pxa.instrhandle, 'FREQuency:STOP?');
    stop = fscanf(pxa.instrhandle, '%f');
end