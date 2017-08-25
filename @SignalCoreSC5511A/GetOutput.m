function output = GetOutput(self)
% Get output status
    status = self.GetStatus();
    output = status.operate_status.rf1_out_enable;
end