function SyncWith(self, master)
% Synchronize with a master AWG
% This code is a HACK
% It ignores the errors and force the program to continue
% Needs to be improved

% Reinitialize master and self
    master.Finalize();
    self.Finalize();
    master.Initialize();
    self.Initialize();

    % Repeat three times to avoid errors
    master.instrhandle.DeviceSpecific.Output.SyncMode = 0;
    self.instrhandle.DeviceSpecific.Output.SyncMode = 1;
    for repeat = 1:3
        try
            master.instrhandle.DeviceSpecific.Output.ConfigureClockSync(1, 0);
        catch
        end
        try
            self.instrhandle.DeviceSpecific.Output.ConfigureClockSync(1, 1);
        catch
        end
    end
    for repeat = 1:3
        try
            master.Generate();
        catch
        end
    end
    for repeat = 1:3
        try
            self.Generate();
        catch
        end
    end
end

