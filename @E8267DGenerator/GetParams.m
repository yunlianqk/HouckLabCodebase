function GetParams(gen)
% Read parameters from instrument and update
    fprintf(gen.instrhandle, 'FREQuency?');
    gen.frequency = fscanf(gen.instrhandle, '%g');
    fprintf(gen.instrhandle, 'POWer?');
    gen.power = fscanf(gen.instrhandle, '%g');
end