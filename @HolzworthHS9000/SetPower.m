function SetPower(self, power)
% Set power
    self.write([':PWR:', num2str(power), 'dBm']);
end