function SetPower(self, power)
% Set power
    self.CheckInstr();
    status = calllib(self.lib, 'sc5511a_set_level', self.instr, power);
end