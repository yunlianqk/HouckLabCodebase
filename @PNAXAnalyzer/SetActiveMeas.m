function SetActiveMeas(pnax, meas)
% Set active measurement
    isactive = 0;
    for channel = pnax.GetChannelList()
        if ismember(meas, pnax.GetMeasList(channel))
            fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', ...
                    [channel, meas]);
            isactive = 1;
            return;
        end
    end
    
    if ~isactive
        fprintf('Measurement ''%s'' does not exist\n', meas);
    end
end