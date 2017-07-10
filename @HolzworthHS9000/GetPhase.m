function phase = GetPhase(self)
% Get phase (in radians)
   phase = str2double(self.write(':PHASE?'))/180*pi;
end