function SetPower(gen, power)
% Set power
    fprintf(gen.instrhandle, 'POWer %g', power);
end