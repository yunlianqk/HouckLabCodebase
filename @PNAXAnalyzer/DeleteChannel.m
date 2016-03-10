function DeleteChannel(pnax, channel)
% Delete a channel
    if ismember(channel, pnax.GetChannelList())
        fprintf(pnax.instrhandle, 'SYSTem:CHANnels:DELete %d', channel);
    end
end