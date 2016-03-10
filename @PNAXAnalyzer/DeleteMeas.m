function DeleteMeas(pnax, channel, meas)
% Delete an existing measurement
    if ismember(meas, pnax.GetMeasList(channel))
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:DELete ''%s''', ...
                [channel, meas]);
    end
end