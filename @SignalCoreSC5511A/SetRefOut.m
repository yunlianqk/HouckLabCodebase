function SetRefOut(self, refout)
% Set reference output
    self.CheckInstr();
    status = self.GetStatus;
    switch upper(refout)
        case '10MHZ'
            calllib(self.lib, 'sc5511a_set_clock_reference', self.instr, ...
                    0, status.operate_status.ext_ref_lock_enable);
        case '100MHZ'
            calllib(self.lib, 'sc5511a_set_clock_reference', self.instr, ...
                    1, status.operate_status.ext_ref_lock_enable);
        otherwise
            disp('refout needs to be ''10MHz'' or ''100MHz''.');
    end
end