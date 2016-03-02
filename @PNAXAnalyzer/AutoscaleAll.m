function AutoscaleAll(pnax) 
% Performs autoscale on PNAX display for all traces y axes
    instr = pnax.instrhandle;
    fprintf(instr, 'DISPlay:WINDow:Y:AUTO');
end