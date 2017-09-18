function PowerOff(self)
% Turns off device output
    self.CheckDevID();
    % Without the pause commands the SetRFOn command is occasionally ignored
    pause(0.1);
    calllib(self.lib, 'fnLMS_SetRFOn', self.devID, 0);
    pause(0.1);
end