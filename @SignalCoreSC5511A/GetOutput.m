function output = GetOutput(self)
    status = self.GetStatus();
    output = status.operate_status.rf1_out_enable;
end