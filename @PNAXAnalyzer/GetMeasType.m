function meastype = GetMeasType(pnax, meas)
% Return the measure type for a given measurement
    meastype = [];
    if ismember(meas, pnax.GetMeasList())
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:CATalog:EXTended?', ...
                pnax.GetActiveChannel());
        tempstr = fscanf(pnax.instrhandle, '%s');
        measlist = strsplit(tempstr(2:end-1), ',');
        idx = find(strcmp(measlist, meas));
        meastype = measlist{idx+1};
    end
end