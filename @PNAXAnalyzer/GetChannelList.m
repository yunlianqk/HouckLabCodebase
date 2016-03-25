function chlist = GetChannelList(pnax)
% Return a line vector containing the existing channels
    fprintf(pnax.instrhandle, 'SYSTem:CHANnels:CATalog?');
    tempstr = fscanf(pnax.instrhandle, '%s');
    chlist = sscanf(tempstr(2:end-1), '%d,');
    chlist = chlist';
end

