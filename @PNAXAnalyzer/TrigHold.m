function TrigHold(pnax, varargin)
% Set trigger to hold
    if isempty(varargin)
        channel = pnax.GetActiveChannel();
    else
        channel = varargin{1};
        if ~ismember(channel, pnax.GetChannelList())
            display('Channel does not exist');
            return;
        end
    end
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:MODE HOLD', channel);
end