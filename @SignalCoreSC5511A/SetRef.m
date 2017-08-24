function SetRef(self, ref)
    status = self.GetStatus;
    if strcmpi(ref, 'EXT')
        if status.operate_status.ext_ref_detect
            calllib(self.lib, 'sc5511a_set_clock_reference', self.instr, ...
                    status.operate_status.ref_out_select, 1);
            return;
        else
            disp('External clock not detected. Internal clock is used.');
        end
    end
    calllib(self.lib, 'sc5511a_set_clock_reference', self.instr, ...
            status.operate_status.ref_out_select, 0);
end