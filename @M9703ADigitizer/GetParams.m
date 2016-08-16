function params = GetParams(self)
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    params = paramlib.m9703a();
    device = self.instrID.DeviceSpecific;

    params.ChI = self.ChI;
    params.ChQ = self.ChQ;
    % Get parameters from the first enabled channel
    params.samplerate = device.Acquisition.SampleRate;
    params.samples = double(device.Acquisition.RecordSize);
    params.segments = self.segments;
    params.averages = double(device.Acquisition.NumRecordsToAcquire/params.segments);
    params.fullscale = device.Channels.Item(params.ChI).Range;
    params.offset = device.Channels.Item(params.ChI).Offset;
    
    if strfind(device.Channels.Item(params.ChI).Coupling, 'DC')
        params.couplemode = 'DC';
    else
        params.couplemode = 'AC';
    end
    
    params.delaytime = device.Trigger.Delay;
    params.trigSource = device.Trigger.ActiveSource;
    params.trigLevel = device.Trigger.Sources.Item(params.trigSource).Level;
    params.trigPeriod = self.trigPeriod;
    
    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end