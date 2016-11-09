function meastype = GetMeasType(pnax, meas)
% Return the measure type for a given measurement
    meastype = [];
    fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:CATalog:EXTended?', ...
            pnax.GetActiveChannel());
    tempstr = fscanf(pnax.instrhandle, '%s');
    measlist = strsplit(tempstr(2:end-1), ',');
    if ismember(meas, measlist)
        idx = find(strcmp(measlist, meas));
        meastype = measlist{idx+1};
    else
        display('Measurement does not exist');
    end
end