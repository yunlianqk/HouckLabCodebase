function current = GetCurrent(yoko)
% Get current
    fprintf(yoko.instrhandle, 'SOURce:FUNCtion CURRent');
    fprintf(yoko.instrhandle, ':SOURce:LEVel?');
    current = fscanf(yoko.instrhandle, '%f');
end