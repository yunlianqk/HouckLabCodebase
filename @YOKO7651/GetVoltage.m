function voltage = GetVoltage(yoko)
% Get voltage
	fprintf(yoko.instrhandle, 'F1;E;');
    fprintf(yoko.instrhandle, 'OD;E;');
    buffer = fscanf(yoko.instrhandle, '%4s%f');
    voltage = buffer(5);
end