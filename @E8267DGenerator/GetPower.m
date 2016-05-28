function power = GetPower(gen)
% Get power
    fprintf(gen.instrhandle, 'POWer?');
    power = fscanf(gen.instrhandle, '%f');
end