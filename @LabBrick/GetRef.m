function ref = GetRef(self)
% Get reference clock source
    switch calllib(self.lib, 'fnLMS_GetUseInternalRef', self.devID)
        case 1
            ref = 'INT';
        case 0
            ref = 'EXT';
        otherwise
    end
end