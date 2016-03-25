function DeleteAll(pnax)
% Delete everything
    for channel = pnax.GetChannelList()
        pnax.DeleteChannel(channel);
    end
end