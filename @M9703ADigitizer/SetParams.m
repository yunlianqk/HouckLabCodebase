function SetParams(self, params)
% Set card parameters
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
%     if isprop(params,'samplerate')~=0
%     self.params.samplerate=params.samplerate;
%     end
%     
%     if isprop(params,'samples')~=0
%     self.params.samples=params.samples;
%     end
%     
%     if isprop(params,'averages')~=0
%     self.params.averages=params.averages;
%     end
%     
%     if isprop(params,'segments')~=0
%     self.params.segments=params.segments;
%     end
%     
%     if isprop(params,'fullscale')~=0
%     self.params.fullscale=params.fullscale;
%     end
%     
%     if isprop(params,'offset')~=0
%     self.params.offset=params.offset;
%     end
%     
%     if isprop(params,'couplemode')~=0
%     self.params.couplemode=params.couplemode;
%     end
%     
%     if isprop(params,'enabled')~=0
%     self.params.enabled=params.enabled;
%     end
%     
%     if isprop(params,'delaytime')~=0
%     self.params.delaytime=params.delaytime;
%     end
%     
%     if isprop(params,'ChI')~=0
%     self.params.ChI=params.ChI;
%     end
%     
%     if isprop(params,'ChQ')~=0
%     self.params.ChQ=params.ChQ;
%     end
%     
%     if isprop(params,'TrigSource')~=0
%     self.params.TrigSource=params.TrigSource;
%     end
%     
%     if isprop(params,'TrigType')~=0
%     self.params.TrigType=params.TrigType;
%     end
%     
%     if isprop(params,'TrigLevel')~=0
%     self.params.TrigLevel=params.TrigLevel;
%     end
%     
%     if isprop(params,'TrigPeriod')~=0
%     self.params.TrigPeriod=params.TrigPeriod;
%     end

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
    
    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end

