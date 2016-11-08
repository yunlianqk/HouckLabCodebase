function SetPhase(gen, phase)
% Set phase (in degrees)
    fprintf(gen.instrhandle, 'PHASe %fDEG', phase);
end