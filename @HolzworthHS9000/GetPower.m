function power = GetPower(self)
% Get power
    power = str2double(self.write(':PWR?'));
end