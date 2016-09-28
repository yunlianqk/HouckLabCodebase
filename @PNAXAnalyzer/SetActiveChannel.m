function SetActiveChannel(pnax, channel)
% Set active channel
    if ismember(channel, pnax.GetChannelList)
        measlist = pnax.GetMeasList(channel);
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', ...
                [channel, measlist{1}]);
    else
        fprintf('Channel %d does not exist\n', channel);
    end
end