function freq = GetFreq(self)
    % Get frequency
    freq = sscanf(self.write(':FREQ?'), '%f MHz')*1e6; % Hardware returns frequency in MHz
end