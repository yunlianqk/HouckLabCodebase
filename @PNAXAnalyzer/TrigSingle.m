function TrigSingle(pnax, varargin)
% Set trigger to single
    if isempty(varargin)
        channel = pnax.GetActiveChannel();
    else
        channel = varargin{1};
        if ~ismember(channel, pnax.GetChannelList())
            display('Channel does not exist');
            return;
        end
    end
    fprintf(pnax.instrhandle, 'SENSe%d:SWEep:MODE SiNGle', channel);
end