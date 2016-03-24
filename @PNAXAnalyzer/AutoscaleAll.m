function AutoscaleAll(pnax) 
% Performs autoscale on PNAX display for all traces y axes
    fprintf(pnax.instrhandle, 'DISPlay:WINDow:Y:AUTO');
end