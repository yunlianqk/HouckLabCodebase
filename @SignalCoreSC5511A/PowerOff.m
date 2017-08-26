function PowerOff(self)
% Turn off power
    self.CheckInstr();
    calllib(self.lib, 'sc5511a_set_output',self.instr,0);
end