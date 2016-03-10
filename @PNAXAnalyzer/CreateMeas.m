function CreateMeas(pnax, channel, trace, meastype)
% Create a measurement
    
    % Name the measurement
    meas = pnax.MeasName(channel, trace, meastype);

    % If measurement does not exist, create it
    if ~ismember(meas, pnax.GetMeasList(channel))
        % Delete the trace if it already exists
        pnax.DeleteTrace(trace);
        % Create the measurement
        fprintf(pnax.instrhandle, sprintf('CALCulate%d:PARameter:EXTended ''%s'', ''%s''', ...
                channel, meas, meastype));
        % Select the measurment
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', [channel, meas]);
        % Feed the measurement to the trace
        fprintf(pnax.instrhandle, 'DISPlay:WINDow:TRACe%d:FEED ''%s''', [trace,meas]);
    % If measurement already exists, modify it
    else
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', [channel, meas]);
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:MODify:EXTended ''%s''', ...
                [channel, meastype]);
    end
end