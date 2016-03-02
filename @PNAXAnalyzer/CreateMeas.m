function CreateMeas(pnax, channel, trace, meastype, format)
% Create a measurement
    
    % If trace already exists, delete it
    trlist = pnax.GetTraces();
    if ismember(trace, trlist)
        fprintf(pnax.instrhandle, ['DISPlay:WINDow:TRACe', num2str(trace), ':DELete']);
    end
    % If measurement already exists, delete it
    measname = pnax.MeasName(channel, trace);
    measlist = pnax.GetMeasurements(channel);
    if ismember(measname, measlist)
        fprintf(pnax.instrhandle, ['CALCulate', num2str(channel), ...
                                   ':PARameter:DELete ', measname]);
    end
    % Create a measurment with the given channel, trace and meas
    fprintf(pnax.instrhandle, ['CALCulate', num2str(channel), ':PARameter:', ...
                               'EXTended ', measname, ', ', meastype]);
    fprintf(pnax.instrhandle, ['DISPlay:WINDow:TRACe', num2str(trace), ...
                                ':FEED ', measname]);
    fprintf(pnax.instrhandle, ['CALCulate', num2str(channel), ':PARameter:', ...
                               'SELect ', measname]);
    fprintf(pnax.instrhandle, ['CALCulate', num2str(channel), ':FORMat ', format]);
end