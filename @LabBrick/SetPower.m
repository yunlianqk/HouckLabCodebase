function SetPower(self, power)
% Set power
    self.CheckDevID();
    % error check power level within bounds of the device
    if power > self.max_power
        power = self.max_power;
        warning('Power out of range');
    elseif power < self.min_power
        power = self.min_power;
        warning('Power out of range');
    end
    % write power as a multiple of 0.25 dBm
    powerTimesFour = int32(power*4);
    calllib(self.lib, 'fnLMS_SetPowerLevel', self.devID, powerTimesFour);
end