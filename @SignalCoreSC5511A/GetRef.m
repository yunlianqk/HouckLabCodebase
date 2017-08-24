function ref = GetRef(self)
    status = self.GetStatus();
    switch status.operate_status.ext_ref_lock_enable
        case 1
            ref = 'EXT';
        case 0
            ref = 'INT';
        otherwise
    end
end