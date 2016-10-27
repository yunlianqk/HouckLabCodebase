function output = GetOutput(yoko)
% Get output status
	fprintf(yoko.instrhandle, 'OC;E;');
    reply = fscanf(yoko.instrhandle, '%s');
    status = sscanf(reply, 'STS1=%d');
    output = bitget(status, 5);
end