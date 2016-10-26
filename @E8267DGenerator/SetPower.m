function SetPower(gen, power)
% Set power
    fprintf(gen.instrhandle, 'POWer %f', power);
end