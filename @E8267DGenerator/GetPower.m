function power = GetPower(self)
% Get power
    fprintf(self.instrhandle, 'POWer?');
    power = fscanf(self.instrhandle, '%f');
end