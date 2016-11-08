function current = GetCurrent(yoko)
% Get current
	fprintf(yoko.instrhandle, 'F5;E;');
    fprintf(yoko.instrhandle, 'OD;E;');
    buffer = fscanf(yoko.instrhandle, '%4s%f');
    current = buffer(5);
end