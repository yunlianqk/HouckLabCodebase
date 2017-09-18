function SetRef(self, ref)
% Set reference clock source
    self.CheckDevID();
    if strcmpi(ref, 'EXT')
        calllib(self.lib, 'fnLMS_SetUseInternalRef', self.devID, false);
        pause(0.2);
        info = self.Info();
        if ~info.PLL_LOCKED
            disp('PLL is not locked. Internal clock is used.');
            ref = 'INT';
        else
            return;
        end
    end
    if strcmpi(ref, 'INT')
        calllib(self.lib, 'fnLMS_SetUseInternalRef', self.devID, true);
    else
        disp('ref needs to be ''INT'' or ''EXT''.');
    end
end