function channel = GetActiveChannel(pnax)
% Return the currently active channel
    if ~isempty(pnax.GetTraceList())
        fprintf(pnax.instrhandle, 'SYSTem:ACTive:CHANnel?');
        channel = fscanf(pnax.instrhandle, '%d');
    else
        channel = [];
    end
end