function trlist = GetTraceList(pnax)
% Return a line vector containing the existing traces
    fprintf(pnax.instrhandle, 'DISPlay:WINDow:CATalog?');
    tempstr = fscanf(pnax.instrhandle, '%s');
    trlist = sscanf(tempstr(2:end-1), '%d,');
    trlist = trlist';
end