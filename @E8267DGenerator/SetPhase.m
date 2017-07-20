function SetPhase(self, phase)
% Set phase (in radians)
    fprintf(self.instrhandle, 'PHASe %fRAD', phase);
end