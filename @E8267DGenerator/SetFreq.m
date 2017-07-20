function SetFreq(self, freq)
% Set frequency
    fprintf(self.instrhandle, 'FREQuency %f', freq);
end