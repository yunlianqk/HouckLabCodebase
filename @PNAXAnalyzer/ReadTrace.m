function data = ReadTrace(pnax,varargin)
% Read a specific trace
    fclose(pnax.instrhandle);
    set(pnax.instrhandle, 'InputBufferSize', 1e6);
    set(pnax.instrhandle, 'Timeout', pnax.timeout);
    fopen(pnax.instrhandle);
    
    if isempty(varargin)
        trace = pnax.GetActiveTrace();
    else
        trace = varargin{1};
    end
    
    if ismember(trace, pnax.GetTraceList())
        pnax.SetActiveTrace(trace);
        % Read data
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', ...
                [pnax.GetActiveChannel(), pnax.GetActiveMeas()]);
        fprintf(pnax.instrhandle, 'CALCulate%d:DATA? FDATA', pnax.GetActiveChannel());
        data = str2num(fscanf(pnax.instrhandle, '%s'));
    else
        fprintf('Trace %d does not exist\n', trace);
        data = [];
    end
    
    fclose(pnax.instrhandle);
    set(pnax.instrhandle,'InputBufferSize',40000);
    fopen(pnax.instrhandle);
end