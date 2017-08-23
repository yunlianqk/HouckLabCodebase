function ClearChannelAverages(pnax, channel)
% Restart specified channel's averaging
    disp(['pnax.ClearChannelAverages(channel) is deprecated. ', ...
          'Use pnax.AvgClear(channel) instead']);
    fprintf(pnax.instrhandle, ['SENS', num2str(channel), ':AVER:CLE']);
end
