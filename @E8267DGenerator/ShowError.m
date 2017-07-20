function ShowError(self)
% Show and clear error messages
    fprintf(self.instrhandle, 'SYSTem:ERRor?');
    message = fscanf(self.instrhandle, '%s');
    while ~strcmp(message, '+0,"Noerror"')
        disp(message);
        fprintf(self.instrhandle, 'SYSTem:ERRor?');
        message = fscanf(self.instrhandle, '%s');
    end
end