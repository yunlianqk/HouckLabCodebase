function SetActiveTrace(pnax, trace)
% Set active trace
    if ismember(trace, pnax.GetTraceList())
        fprintf(pnax.instrhandle, 'DISPlay:WINDow:TRACe%d:SELect', trace);
    else
        fprintf('Trace %d does not exist\n', trace);
    end
end