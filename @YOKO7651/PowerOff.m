function PowerOff(yoko)
% Turn off output
    fprintf(yoko.instrhandle, 'O0;E;');
end