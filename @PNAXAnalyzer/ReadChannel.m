function dataarray = ReadChannel(pnax,varargin)
% Read all traces in a channel
    fclose(pnax.instrhandle);
    set(pnax.instrhandle, 'InputBufferSize', 1e6);
    set(pnax.instrhandle, 'Timeout', pnax.timeout);
    fopen(pnax.instrhandle);
    
    if isempty(varargin)
        channel = pnax.GetActiveChannel();
    else
        channel = varargin{1};
    end
    
    if ismember(channel, pnax.GetChannelList())
        % Read data
        measlist = pnax.GetMeasList(channel);
        dataarray = zeros(length(measlist), pnax.GetParams().points);
        for idx = 1:length(measlist)
            fprintf(pnax.instrhandle, 'CALCulate%d:PARameter:SELect ''%s''', ...
                    [channel, measlist{idx}]);
            fprintf(pnax.instrhandle, 'CALCulate%d:DATA? FDATA', pnax.GetActiveChannel());
            dataarray(idx, :) = str2num(fscanf(pnax.instrhandle, '%s'));
        end
    else
        fprintf('Channel %d does not exist\n', channel);
        dataarray = [];
    end
    
    fclose(pnax.instrhandle);
    set(pnax.instrhandle,'InputBufferSize',40000);
    fopen(pnax.instrhandle);
end