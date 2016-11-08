function SetMode(yoko, mode)
% Set mode
	switch mode
        case 'voltage'
            fprintf(yoko.instrhandle, 'SOURce:FUNCtion VOLTage');
        case 'current'
            fprintf(yoko.instrhandle, 'SOURce:FUNCtion CURRent');
        otherwise
            display('Unknown output mode.');
    end
end