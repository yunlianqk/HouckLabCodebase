function voltage = GetVoltage(yoko)
% Get voltage
    fprintf(yoko.instrhandle, 'OD;E;');
    buffer = fscanf(yoko.instrhandle, '%4s%e');
    voltage = buffer(5);
end