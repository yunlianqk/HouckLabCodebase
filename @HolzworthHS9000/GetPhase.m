function phase = GetPhase(self)
% Get phase (in degrees)
   phase = str2double(self.write(':PHASE?'))/180*pi;
end