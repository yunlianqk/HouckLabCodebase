function ShowError(yoko)
% Show and clear error messages
    fprintf(yoko.instrhandle, 'SYSTem:ERRor?');
    message = fscanf(yoko.instrhandle, '%s');
    while ~strcmp(message, '0,"Noerror"')
        disp(message);
        fprintf(yoko.instrhandle, 'SYSTem:ERRor?');
        message = fscanf(yoko.instrhandle, '%s');
    end
end