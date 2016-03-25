function AutoScale(pnax, varargin)
% Auto scale the currently active trace
    if isempty(varargin)
        trace = pnax.GetActiveTrace();
    else
        trace = varargin{1};
        if ~ismember(trace, pnax.GetTraceList())
            display('Channel does not exist');
            return;
        end
    end
    fprintf(pnax.instrhandle, 'DISPlay:WINDow:TRACe%d:Y:AUTO', trace);
end