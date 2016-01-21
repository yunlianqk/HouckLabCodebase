function data = Read(pnax)
% Return the currently active trace
    fclose(pnax.instrhandle);
    set(pnax.instrhandle, 'InputBufferSize', 1e6);
    set(pnax.instrhandle, 'Timeout', 30);
    fopen(pnax.instrhandle);
    
    % Get the currently active channel and measurement
    fprintf(pnax.instrhandle, 'SYSTem:ACTive:CHANnel?');
    channel = fscanf(pnax.instrhandle, '%d');
    fprintf(pnax.instrhandle, 'SYSTem:ACTive:MEASurement?');
    measurement = fscanf(pnax.instrhandle, '%s');
    % Read data
    fprintf(pnax.instrhandle,['calc', num2str(channel), ':par:sel ', measurement]);
    fprintf(pnax.instrhandle,['calc', num2str(channel), ':data? fdata']);
    data = str2num(fscanf(pnax.instrhandle, '%s'));

    fclose(pnax.instrhandle);
    set(pnax.instrhandle,'InputBufferSize',40000);
    fopen(pnax.instrhandle);
end