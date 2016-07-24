function params = GetParams(self)
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    params = paramlib.m9703a();
    device = self.instrID.DeviceSpecific;
    % Get enabled channel numbers
    chList = [];
    for ch = 1:8
        if device.Channels.Item(device.Channels.Name(ch)).Enabled == 1
            chList(end + 1) = ch;
        end
    end
    if length(chList) < 2
        display('Less than two channels are enabled');
        return;
    end
    
    % Assigned first two enabled channels to ChI and ChQ
    params.ChI = device.Channels.Name(chList(1));
    params.ChQ = device.Channels.Name(chList(2));
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