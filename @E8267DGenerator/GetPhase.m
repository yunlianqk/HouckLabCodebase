function phase = GetPhase(gen)
% Get phase (in degrees)
    fprintf(gen.instrhandle, 'PHASe?');
    phase = fscanf(gen.instrhandle, '%f')/pi*180;
end