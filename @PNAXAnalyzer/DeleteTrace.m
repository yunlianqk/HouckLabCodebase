function DeleteTrace(pnax, trace)
% Delete an existing trace
    for channel = pnax.GetChannelList()
        measlist = pnax.GetMeasList(channel);
        for idx = 1:length(measlist)
            if ~isempty(strfind(measlist{idx}, ['_', num2str(trace)]))
                pnax.DeleteMeas(channel, measlist{idx});
            end
        end
    end
    
    if ismember(trace, pnax.GetTraceList())
        fprintf(pnax.instrhandle, 'DISPlay:WINDow:TRACe%d:DELete', trace);
    end
end