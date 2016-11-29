function WaitTrigger(self)

    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    self.instrID.DeviceSpecific.Acquisition.Abort();
    self.instrID.DeviceSpecific.Acquisition.Initiate();
    self.waittrig = 1;

end