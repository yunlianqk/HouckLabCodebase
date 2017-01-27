function SetParams(self, params)
% Set card parameters
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');

    % Check parameters
    if ~self.CheckParams(params)
        display('Parameters are not set correctly.');
        return;
    end

    % Get device handle
    device = self.instrID.DeviceSpecific;
    % Get coupling mode
    if strcmp(params.couplemode, 'DC')
        coupling = 1;
    elseif strcmp(params.coupledmode, 'AC')
        coupling = 0;
    else
        display('Unknow couplemode');
    end
    
    % Setup acquisition
    device.Acquisition.ConfigureAcquisition( ...
        params.averages*params.segments,...
        params.samples,...
        params.samplerate);
    self.segments = params.segments;
    
    % Enable ChI and ChQ
    for ch = 1:8
        pCh = device.Channels.Item(device.Channels.Name(ch));
        if ismember(device.Channels.Name(ch), {params.ChI, params.ChQ})
            enabled = 1;
        else
            enabled = 0;
        end
        pCh.Configure(params.fullscale, params.offset, coupling, enabled);
    end
    self.ChI = params.ChI;
    self.ChQ = params.ChQ;
    
    % Setup trigerring
    device.Trigger.ActiveSource = params.trigSource;
    device.Trigger.Delay = params.delaytime;
    pTrig = device.Trigger.Sources.Item(params.trigSource);
    pTrig.Type = 'AgMD1TriggerEdge';  % This seems to be the only supported trigger type
    pTrig.Level= params.trigLevel;
    self.trigPeriod = params.trigPeriod;
    if params.trigPeriod < params.delaytime+params.samples/params.samplerate
        warning('card.trigPeriod is shorter than delay + acquisition time');
    end
    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    clear device;
end

