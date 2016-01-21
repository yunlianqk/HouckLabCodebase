function Finalize(pulsegen)
% Close instrhandle
    if pulsegen.instrhandle.Initialized == 1
%         pulsegen.instrhandle.AbortGeneration();
        pulsegen.instrhandle.Close();
    end
end