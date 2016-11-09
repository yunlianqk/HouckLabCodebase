function Reset(yoko)
% Reset instrument
    fprintf(yoko.instrhandle, 'RC;E;');
end