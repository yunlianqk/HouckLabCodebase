function SetFreq(self, freq)
    % Set frequency
    self.CheckInstr();
    status = calllib(self.lib, 'sc5511a_set_freq', self.instr, freq); % 0.001Hz resolution according to datasheet
end