function refin = GetRefIn(self)
% Get reference clock source
    self.CheckInstr();
    status = self.GetStatus();
    switch status.operate_status.ext_ref_lock_enable
        case 1
            refin = 'EXT';
        case 0
            refin = 'INT';
        otherwise
    end
end