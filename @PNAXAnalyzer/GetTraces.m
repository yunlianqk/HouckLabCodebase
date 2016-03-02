function trlist = GetTraces(pnax)
% Get the existing traces
    fprintf(pnax.instrhandle, 'DISPlay:WINDow:CATalog?');
    tempstr = fscanf(pnax.instrhandle, '%s');
    trlist = sscanf(tempstr(2:end-1), '%d,');
    trlist = trlist';
end