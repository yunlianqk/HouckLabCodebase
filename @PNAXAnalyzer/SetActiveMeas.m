function SetActiveMeas(pnax, meas)
% Set active measurement
    isactive = 0;
    if isnumeric(meas)
        fprintf(pnax.instrhandle, 'SYSTem:MEASurement%d:NAME?', meas);
        tempstr = fscanf(pnax.instrhandle, '%s');
        meas = tempstr(2:end-1);
    end
    
    for channel = pnax.GetChannelList()
        if ismember(meas, pnax.GetMeasList(channel))
            fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', ...
                    [channel, meas]);
            isactive = 1;
            return;
        end
    end
    
    if ~isactive
        display('Measurement does not exist');
    end
end