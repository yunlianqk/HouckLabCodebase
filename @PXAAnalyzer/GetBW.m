function bw = GetBW(pxa)
% Get bw
    fprintf(pxa.instrhandle, ':SENSE:BAND?');
    bw = fscanf(pxa.instrhandle, '%f');
end