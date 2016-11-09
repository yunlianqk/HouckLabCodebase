function start = GetStartFreq(pxa)
% Get start frequency
    fprintf(pxa.instrhandle, 'FREQuency:STARt?');
    start = fscanf(pxa.instrhandle, '%f');
end