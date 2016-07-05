function isspec = IsSpec(pnax, channel)
% Check if a channel is spectroscopy measurement
    fprintf(pnax.instrhandle, 'SENSe%d:FOM:STATe?', channel);
    isspec = fscanf(pnax.instrhandle, '%d');
end