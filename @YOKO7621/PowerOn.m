function PowerOn(yoko)
% Turn on output
    fprintf(yoko.instrhandle, 'O1;E;');
end