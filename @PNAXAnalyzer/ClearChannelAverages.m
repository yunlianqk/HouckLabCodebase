function ClearChannelAverages(pnax,channel)
% Restart specified channel's averaging
    fprintf(pnax.instrhandle, ['SENS', num2str(channel), ':AVER:CLE']);
end
