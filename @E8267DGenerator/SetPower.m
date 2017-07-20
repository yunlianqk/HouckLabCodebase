function SetPower(self, power)
% Set power
    fprintf(self.instrhandle, 'POWer %f', power);
end