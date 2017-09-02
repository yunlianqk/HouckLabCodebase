function refout = GetRefOut(self)
% Get reference output
    self.CheckInstr();
    status = self.GetStatus();
    switch status.operate_status.ref_out_select
        case 0
            refout = '10MHz';
        case 1
            refout = '100MHz';
        otherwise
    end
end