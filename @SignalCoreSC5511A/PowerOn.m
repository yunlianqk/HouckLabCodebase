function PowerOn(self)
% Turn on power
    self.CheckInstr();
    calllib(self.lib, 'sc5511a_set_output',self.instr,1);
end