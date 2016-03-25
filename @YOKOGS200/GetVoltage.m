function voltage = GetVoltage(yoko)
% Get voltage
    fprintf(yoko.instrhandle, ':SOURce:LEVel?');
    voltage = fscanf(yoko.instrhandle, '%g');
end