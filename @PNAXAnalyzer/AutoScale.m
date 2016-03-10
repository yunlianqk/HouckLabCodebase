function AutoScale(pnax)
% Auto scale the currently active trace
    fprintf(pnax.instrhandle, 'DISPlay:WINDow:TRACe%d:Y:AUTO', pnax.GetActiveTrace());
end