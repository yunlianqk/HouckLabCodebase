function measlist = GetMeasurements(pnax, channel)
% Get existing measurements in a channel
    fprintf(pnax.instrhandle, ['CALCulate', num2str(channel), ':PARameter:CATalog?']);
    tempstr = fscanf(pnax.instrhandle, '%s');
    measlist = strsplit(tempstr(2:end-1), ',');
end