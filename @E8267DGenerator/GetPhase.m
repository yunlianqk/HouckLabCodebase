function phase = GetPhase(self)
% Get phase (in radians)
    fprintf(self.instrhandle, 'PHASe?');
    phase = fscanf(self.instrhandle, '%f');
end