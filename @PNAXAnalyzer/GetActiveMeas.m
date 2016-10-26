function meas = GetActiveMeas(pnax)
% Return the currently active measurement
    if ~isempty(pnax.GetTraceList())
        fprintf(pnax.instrhandle, 'SYSTem:ACTive:MEASurement?');
        meas = fscanf(pnax.instrhandle, '%s');
        meas = meas(2:end-1);
    else
        meas = [];
    end
end

