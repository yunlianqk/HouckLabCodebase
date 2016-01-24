function GetChannels(pnax)
% Get the existing channels
    fprintf(pnax.instrhandle, 'SYSTem:CHANnels:HOLD');
    fprintf(pnax.instrhandle, 'SYSTem:CHANnels:CATalog?');
    tempstr = fscanf(pnax.instrhandle, '%s');
    pnax.channels = sscanf(tempstr(2:end-1), '%d,');
    pnax.channels = pnax.channels';
end