function SetMode(yoko, mode)
% Set mode
    switch mode
        case 'voltage'
            fprintf(yoko.instrhandle, 'F1;E;');
        case 'current'
            fprintf(yoko.instrhandle, 'F5;E;');
        otherwise
            display('Unknown output mode.');
    end
end