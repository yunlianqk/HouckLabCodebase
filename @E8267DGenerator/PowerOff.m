function PowerOff(gen)
% Turn off power
    fprintf(gen.instrhandle, 'OUTPut 0');
end