function ShowError(gen)
% Show and clear error messages
    fprintf(gen.instrhandle, 'SYSTem:ERRor?');
    message = fscanf(gen.instrhandle, '%s');
    while ~strcmp(message, '+0,"Noerror"')
        disp(message);
        fprintf(gen.instrhandle, 'SYSTem:ERRor?');
        message = fscanf(gen.instrhandle, '%s');
    end
end