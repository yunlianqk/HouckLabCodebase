function SetActiveMeas(pnax, meas)
% Set active measurement
    if isnumeric(meas)
        fprintf(pnax.instrhandle, 'SYSTem:MEASurement%d:NAME?', meas);
        tempstr = fscanf(pnax.instrhandle, '%s');
        meas = tempstr(2:end-1);
    end
    
    for channel = pnax.GetChannelList()
        if ismember(meas, pnax.GetMeasList(channel))
            fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', ...
                    [channel, meas]);
            return;
        end
    end
    
    display('Measurement does not exist');
end