function mode = GetMode(yoko)
% Get mode
    fprintf(yoko.instrhandle, 'SOURce:FUNCtion?');
    switch fscanf(yoko.instrhandle, '%s')
        case 'VOLT'
            mode = 'voltage';
        case 'CURR'
            mode = 'current';
    end
end