function trace = GetActiveTrace(pnax)
% Return the currently active trace
    meas = pnax.GetActiveMeas();
    if isempty(meas)
        trace = [];
    else
        tempstr = strsplit(meas, '_');
        trace = sscanf(tempstr{3}, '%d');
    end
end