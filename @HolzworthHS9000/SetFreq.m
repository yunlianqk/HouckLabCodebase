function SetFreq(self, freq)
    % Set frequency
    self.write(sprintf(':FREQ:%.3f Hz', freq)); % 0.001Hz resolution according to datasheet
end