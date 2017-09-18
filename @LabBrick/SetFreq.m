function SetFreq(self,freq)
%Set frequency in Hz
    self.CheckDevID();
    % Error check that the frequency is within the bounds of the device
    if freq > self.max_freq
          freq = self.max_freq;
          warning('Frequency out of range');
    elseif freq < self.min_freq
          freq = self.min_freq;
          warning('Frequency out of range');
    end

    % write frequency in 10s of Hz, 100 Hz resolution
    calllib(self.lib, 'fnLMS_SetFrequency', self.devID, freq/10);
end