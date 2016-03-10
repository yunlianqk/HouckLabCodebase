function measlist = GetMeasList(pnax, varargin)
% Return a string cell array containing the existing measurements
    measlist = [];
    if isempty(varargin)
        channel = pnax.GetActiveChannel();
    else
        channel = varargin{1};
    end
    
    if ismember(channel, pnax.GetChannelList())
        fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:CATalog:EXTended?', channel);
        tempstr = fscanf(pnax.instrhandle, '%s');
        measlist = strsplit(tempstr(2:end-1), ',');
        measlist = measlist(1:2:end);
    end
end