function SetPhase(self, phase)
% Set phase (in radians)
    self.write([':PHASE:', num2str(phase/pi*180), 'deg']);
end