function s = Info(yoko)
% Get instrument info
    fprintf(yoko.instrhandle, 'OS;E;');
    s = fscanf(yoko.instrhandle, '%s');
    while ~strcmp(fscanf(yoko.instrhandle, '%s'), 'END')
    end
end