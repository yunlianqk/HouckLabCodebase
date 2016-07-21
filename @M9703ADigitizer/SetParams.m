function SetParams( self,params )
% Set card parameters
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    if isprop(params,'samplerate')~=0
    self.params.samplerate=params.samplerate;
    end
    
    if isprop(params,'samples')~=0
    self.params.samples=params.samples;
    end
    
    if isprop(params,'averages')~=0
    self.params.averages=params.averages;
    end
    
    if isprop(params,'segments')~=0
    self.params.segments=params.segments;
    end
    
    if isprop(params,'fullscale')~=0
    self.params.fullscale=params.fullscale;
    end
    
    if isprop(params,'offset')~=0
    self.params.offset=params.offset;
    end
    
    if isprop(params,'couplemode')~=0
    self.params.coupledmode=params.coupledmode;
    end
    
    if isprop(params,'enabled')~=0
    self.params.enabled=params.enabled;
    end
    
    if isprop(params,'delaytime')~=0
    self.params.delaytime=params.delaytime;
    end
    
    if isprop(params,'ChI')~=0
    self.params.ChI=params.ChI;
    end
    
    if isprop(params,'ChQ')~=0
    self.params.ChQ=params.ChQ;
    end
    
    if isprop(params,'TrigSource')~=0
    self.params.TrigSource=params.TrigSource;
    end
    
    if isprop(params,'TrigType')~=0
    self.params.TrigType=params.TrigType;
    end
    
    if isprop(params,'TrigLevel')~=0
    self.params.TrigLevel=params.TrigLevel;
    end
    
    if isprop(params,'TrigPeriod')~=0
    self.params.TrigPeriod=params.TrigPeriod;
    end
    
    % Create pointers for I and Q channels and trigger source
    [pChI]=self.instrID.DeviceSpecific.Channels.Item(params.ChI);
    [pChQ]=self.instrID.DeviceSpecific.Channels.Item(params.ChQ);
    [pTrig]=self.instrID.DeviceSpecific.Trigger.Sources.Item(params.TrigSource);
    
    %Setup acquisition
    self.instrID.DeviceSpecific.Acquisition.ConfigureAcquisition( ....
        params.averages,....
        params.samples,...
        params.samplerate);
    pChI.Configure(params.fullscale,...
        params.offset,...
        params.coupledmode,...
        params.enabled);
    pChQ.Configure(params.fullscale,...
        params.offset,...
        params.coupledmode,...
        params.enabled);
    
    %Setup trigerring
    self.instrID.DeviceSpecific.Trigger.ActiveSource = params.TrigSource;
    self.instrID.DeviceSpecific.Trigger.Delay = params.delaytime;
    pTrig.Type = params.TrigType;
    pTrig.Level= params.TrigLevel;
    

    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end

