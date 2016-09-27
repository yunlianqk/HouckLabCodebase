function voltage = GetVoltage(yoko)
% Get voltage
    fprintf(yoko.instrhandle, 'SOURce:FUNCtion VOLTage');
    fprintf(yoko.instrhandle, ':SOURce:LEVel?');
    voltage = fscanf(yoko.instrhandle, '%f');
end