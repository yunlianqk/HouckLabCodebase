function SetParams(self, params)
% Set card parameters
%     warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
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
%     device = self.instrID.DeviceSpecific;
    % Get coupling mode
    if strcmp(params.couplemode, 'DC')
        coupling = 1;
    elseif strcmp(params.coupledmode, 'AC')
        coupling = 0;
    else
        display('Unknow couplemode');
    end

    % Enable ChI and ChQ
    for ch = 1:8
        pCh = {'Channel1', 'Channel2', 'Channel3', 'Channel4',...
               'Channel5', 'Channel6', 'Channel7', 'Channel8'};
        if ismember(pCh(ch), {params.ChI, params.ChQ})
            enabled = 1;
        else
            enabled = 0;
        end
%         pCh.Configure(params.fullscale, params.offset, coupling, enabled);
        invoke(self.instrID.Configurationchannel, 'configurechannel', pCh{ch},...
            params.fullscale, params.offset, coupling, enabled);
    end
    self.ChI = params.ChI;
    self.ChQ = params.ChQ;

    % Set the acquisition parameters
    invoke(self.instrID.Configurationacquisition, 'configureacquisition',...
        1, params.samples, params.samplerate);
    
    % Setup trigerring
    invoke(self.instrID.Configurationtrigger,'configureedgetriggersource',...
    params.trigSource, params.trigLevel, 1);
end

