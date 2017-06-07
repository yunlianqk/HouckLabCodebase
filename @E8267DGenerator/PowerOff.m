function PowerOff(self)
% Turn off power
    fprintf(self.instrhandle, 'OUTPut 0');
end