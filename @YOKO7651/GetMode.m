function mode = GetMode(yoko)
% Get mode
	fprintf(yoko.instrhandle, 'OD;E;');
    buffer = fscanf(yoko.instrhandle, '%4s%f');
    switch char(buffer(4))
        case 'V'
            mode = 'voltage';
        case 'A'
            mode = 'current';
    end
end