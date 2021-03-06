function SetParams(self, params)
% Set card parameters
 
    % Check params class
    if ~isa(params, 'paramlib.acqiris')
        error('params needs to be ''paramlib.acqiris'' object');
    end
    
    % Vertical settings
    Vertbandwidth = 0; % 5 = 35 MHz LPF
    if (strcmp(params.couplemode,'AC'))
        Vertcoupling = 4; % 4 = AC coupled, 50 Ohm
    elseif (strcmp(params.couplemode,'DC'))
        Vertcoupling = 3; % 3 = DC coupled, 50 Ohm
    else
        error('couplemode should be ''DC'' or ''AC''');
    end
        
    for channel = 1:2
        status = AqD1_configVertical(self.instrID, channel, params.fullscale, ...
                                     params.offset, Vertcoupling, Vertbandwidth);
        if status
            error('Error:Vert',...
                  ['Error in vertical settings\n', ...
                   'Fullscale can be 0.05 V to 5 V in 1, 2, 5 sequence\n', ...
                   'Offset can be within +/- 2 V for 0.05/0.5 FS, and +/- 5 V for 1 to 5 V FS']);
        end
    end
    % Horizontal settings
    status = AqD1_configHorizontal(self.instrID, params.sampleinterval, params.delaytime);
    if status
        error('Sampling interval can be 1 ns to 2048 ns in 2^n sequence.');
    end
    % configure the delay parameters
    % delaytime as configured by confighorsettings is ignored
    % StartDelay must be multiple of 16
    StartDelay = floor(params.delaytime/params.sampleinterval/16)*16;
    for channel = 1:2
        status = AqD1_configAvgConfigInt32(self.instrID, channel, 'StartDelay', StartDelay);
        if status
            error('Error setting delay time');
        end
    end
    % Averaging settings
    
    if params.averages > self.maxAvg
        error(['Error setting averages. Max number of averages is ', num2str(self.maxAvg)]);
    end
    if params.segments > self.maxSeg
        error(['Error setting segments. Max number of segments is ', num2str(self.maxSeg)]);
    end
    % NbrSamples must be multiple of 2048
    params.samples = ceil(params.samples/2048)*2048;
    if (params.samples > 2^18)
        display('Warning: Make sure samples <= 2^18');
    end
    if (params.samples * params.segments > 2^25)
        display('Warning: Make sure samples * segments <= 2^25');
    end
    for channel = 1:2
        status = AqD1_configAvgConfigInt32(self.instrID, channel, 'NbrSamples', params.samples);
        if status < 0
            error('Error setting number of samples');
        end
        
        status = AqD1_configAvgConfigInt32(self.instrID, channel, 'NbrSegments', params.segments);
        if status < 0
            error('Error setting number of segments');
        end
        status = AqD1_configAvgConfigInt32(self.instrID, channel, 'NbrWaveforms', params.averages);
        if status < 0
            error('Error setting number of averages');
        end       
        AqD1_configAvgConfigInt32(self.instrID, channel, 'DitherRange',0);
        AqD1_configAvgConfigInt32(self.instrID, channel, 'TrigResync', 0);
    end

    % Trigger settings
    if isempty(regexp(params.trigSource, '(Channel[1-2]|External[1])', 'once'))
        error('Error: trigSource needs to be ''External1'' or ''Channel1-2''');
    end
    switch params.trigSource
        case 'External1'
            trigPattern = '80000000';
            trigCh = -1;
            trigLevel = params.trigLevel * 1000;
        case 'Channel1'
            trigPattern = '00000001';
            trigCh = 1;
            trigLevel = params.trigLevel * 100;
        case 'Channel2'
            trigPattern = '00000002';
            trigCh = 2;
            trigLevel = params.trigLevel * 100;
        otherwise
            error('Error: Unknown trigSource');
    end
    status = AqD1_configTrigClass(self.instrID, 0, hex2dec(trigPattern), 0, 0, 0.0, 0.0);
    % second parameter = 0 sets trigclass to edge trigger
    % third parameter = '80000000' sets trigsource to external trigger 1
    % last 4 parameters are unused
    if status
        error('Error setting trigger source');
    end
    status = AqD1_configTrigSource(self.instrID, trigCh, 0, 0, trigLevel, 0.0);
    % second parameter = -1 sets trigger channel to external sources
    % third parameter = 0/1 sets trigger coupling to DC/AC
    % fourth parameter = 0/1/2/3 sets trigger slope to 
    %                    positive/negative/out of window/into window
    % fifth parameter sets trigger level
    % sixth parameter sets trigger level 2 when window trigger is used
    if status
        error(['Error setting trigger level\n', ...
               'Trigger level can be with +/- 2.5 V for external trigger ', ...
               'or +/- 0.5 for internal trigger']);
    end
    
    % Set up AqReadParameters for readIandQ
    self.AqReadParameters.DelaySamples = StartDelay;
    self.AqReadParameters.dataType = 3; % 3 = 64 bit real, 2 = 32 bit int
    self.AqReadParameters.readMode = 2; % 2 = averaged waveform
    self.AqReadParameters.firstSegment = 0;
    self.AqReadParameters.nbrSegments = params.segments;
    self.AqReadParameters.firstSampleInSeg = 0;
    self.AqReadParameters.nbrSamplesInSeg = params.samples;
    self.AqReadParameters.segmentOffset = params.samples;
    self.AqReadParameters.dataArraySize = (params.samples+32)*params.segments*8; % in bytes, 32 bit int is 4 bytes
    self.AqReadParameters.segDescArraySize = 40*params.segments;
    self.AqReadParameters.flags = 0;
    self.AqReadParameters.reserved = 0;
    self.AqReadParameters.reserved2 = 0;
    self.AqReadParameters.reserved3 = 0;
    self.AqReadParameters.trigPeriod = params.trigPeriod;
    self.AqReadParameters.timeOut = ceil((StartDelay+params.samples)*params.sampleinterval/params.trigPeriod) ...
        *params.trigPeriod*params.averages*params.segments + 1;
end