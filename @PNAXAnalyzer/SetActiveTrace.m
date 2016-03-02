function SetActiveTrace(pnax, trace)
% Set active trace
    trlist = pnax.GetTraces();
    if ~ismember(trace, trlist)
        error(['Error: Trace ', num2str(trace), ' does not exist.']);
    end
    
    fprintf(pnax.instrhandle, ['DISPlay:WINDow:TRACe', num2str(trace), ':SELect']);
end