function xaxis = GetAxis(pnax)
% Return the x-axis of the currently active channel
    fclose(pnax.instrhandle);
    set(pnax.instrhandle, 'InputBufferSize', 1e6);
    set(pnax.instrhandle, 'Timeout', 30);
    fopen(pnax.instrhandle);

    fprintf(pnax.instrhandle, 'SYSTem:ACTive:CHANnel?');
    channel = fscanf(pnax.instrhandle, '%d');
    fprintf(pnax.instrhandle,['sens' num2str(channel) ':x?']);
    xaxis = str2num(fscanf(pnax.instrhandle, '%s'));

    fclose(pnax.instrhandle);
    set(pnax.instrhandle,'InputBufferSize',40000);
    fopen(pnax.instrhandle);
end