function power = GetPower(self)
% Get power in dBm
    self.CheckDevID();
    % Get attenuation from the max output power, in an integer multiple of 0.25dBm.
    attenuation = calllib(self.lib', 'fnLMS_GetPowerLevel', self.devID) / 4;
    % Get power
    power = self.max_power - attenuation;
end