function phase = GetPhase(self)
% Get phase (in degrees)
    fprintf(self.instrhandle, 'PHASe?');
    phase = fscanf(self.instrhandle, '%f')/pi*180;
end