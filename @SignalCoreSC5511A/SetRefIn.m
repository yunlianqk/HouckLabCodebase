function SetRefIn(self, refin)
% Set reference clock source
    self.CheckInstr();
    status = self.GetStatus;
    if strcmpi(refin, 'EXT')
        if status.operate_status.ext_ref_detect
            calllib(self.lib, 'sc5511a_set_clock_reference', self.instr, ...
                    status.operate_status.ref_out_select, 1);
            return;
        else
            disp('External clock not detected. Internal clock is used.');
            refin = 'INT';
        end
    end
    if strcmpi(refin, 'INT')
        calllib(self.lib, 'sc5511a_set_clock_reference', self.instr, ...
                status.operate_status.ref_out_select, 0);
    else
        disp('refin needs to be ''EXT'' or ''INT''.');
    end
end