function freq = GetFreq(self) 
    % returns freq in Hz, (device function returns in 10s of Hz)
    self.CheckDevID();
    freq = calllib(self.lib, 'fnLMS_GetFrequency', self.devID) * 10;
end