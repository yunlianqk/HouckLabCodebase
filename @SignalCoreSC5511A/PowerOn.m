function PowerOn(self)
% Turn on power
    calllib(self.lib, 'sc5511a_set_output',self.instr,1);
end