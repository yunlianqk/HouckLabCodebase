function SetPhase(gen, phase)
% Set phase (in radians)
    fprintf(gen.instrhandle, 'PHASe %fRad', phase);
end