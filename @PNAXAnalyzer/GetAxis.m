function xaxis = GetAxis(pnax)
% Return the x-axis of the currently active channel
    fclose(pnax.instrhandle);
    set(pnax.instrhandle, 'InputBufferSize', 1e6);
    set(pnax.instrhandle, 'Timeout', pnax.timeout);
    fopen(pnax.instrhandle);

    fprintf(pnax.instrhandle, 'SENSe%d:X?', pnax.GetActiveChannel());
    xaxis = str2num(fscanf(pnax.instrhandle, '%s'));

    fclose(pnax.instrhandle);
    set(pnax.instrhandle,'InputBufferSize',40000);
    fopen(pnax.instrhandle);
end