function output = GetOutput(self)
% Return output, 0/1
    self.CheckDevID();
    output = calllib(self.lib, 'fnLMS_GetRF_On', self.devID);
end