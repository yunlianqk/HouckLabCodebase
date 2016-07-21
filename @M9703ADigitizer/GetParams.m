function params = GetParams(self)
    params=paramlib.m9703a();
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    params.samplerate=self.instrID.DeviceSpecific.Acquisition.SampleRate;
    params.samples=self.instrID.DeviceSpecific.Acquisition.RecordSize;
    params.averages=self.instrID.DeviceSpecific.Acquisition.NumRecordsToAcquire;
    params.segments=self.instrID.DeviceSpecific.Acquisition.NumAcquiredRecords;
    params.fullscale=self.instrID.DeviceSpecific.Channels.Item(self.params.ChI).Range;
    params.offset=self.instrID.DeviceSpecific.Channels.Item(self.params.ChI).Offset;
    params.coupledmode=self.instrID.DeviceSpecific.Channels.Item(self.params.ChI).Coupling;
    params.enabled=self.instrID.DeviceSpecific.Channels.Item(self.params.ChI).Enabled;
    params.delaytime=self.instrID.DeviceSpecific.Trigger.Delay;
    params.TrigSource=self.instrID.DeviceSpecific.Trigger.ActiveSource;
    params.TrigType=self.instrID.DeviceSpecific.Trigger.Sources.Item(self.params.TrigSource).Type;
    params.TrigLevel=self.instrID.DeviceSpecific.Trigger.Sources.Item(self.params.TrigSource).Level;
    
    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end