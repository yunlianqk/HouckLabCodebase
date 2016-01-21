function GetVoltage(yoko)
% Get voltage
    fprintf(yoko.instrhandle, ':SOURce:LEVel?');
    yoko.voltage = fscanf(yoko.instrhandle, '%g');
end