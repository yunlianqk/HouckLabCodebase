function SetParams(self, params)
% Set card parameters
    
    % Vertical settings
    Vertoffset = 0;
    Vertbandwidth = 0; % 5= 35 MHz LPF
    if (strcmp(params.couplemode,'AC'))
        Vertcoupling = 4; % 4 = AC coupled, 50 Ohm
    elseif (strcmp(params.couplemode,'DC'))
        Vertcoupling = 3; % 3 = DC coupled, 50 Ohm
    else
        error('params.couplemode should be ''DC'' or ''AC''')
    end
        
    for channel = 1:2
        status = AqD1_configVertical(self.instrID, channel, params.fullscale, ...
                                     Vertoffset, Vertcoupling, Vertbandwidth);
        if status ~= 0
            error('Error in vertical settings. Fullscale can be 0.05 V to 5 V in 1, 2, 5 sequence.');
        end
    end
    % Horizontal settings
    status = AqD1_configHorizontal(self.instrID, params.sampleinterval, params.delaytime);
    if status ~= 0
        error('Error in horizontal settings. Sampling interval can be 1 ns to 0.1 ms in 1, 2, 2.5, 4, 5 sequence.');
    end
    % configure the delay parameters
    % delaytime as configured by confighorsettings is ignored
    % StartDelay must be multiple of 16
    StartDelay = params.delaytime/params.sampleinterval;
    StartDelay = floor(StartDelay/16)*16;
    for channel = 1:2
        status = AqD1_configAvgConfigInt32(self.instrID, channel, 'StartDelay', StartDelay);
        if status ~= 0
            error('Error setting delay time');
        end
    end
    % Averaging settings
    % NbrRoundRobins is used instead of NbrWavefroms so that averaging
    % works for mulitsegment acquisition as well
    maxAvg = 65536;
    softAvg = ceil(params.averages/maxAvg);
    NbrRoundRobins = ceil(params.averages/softAvg);
    % For multi segment mode, max avg is 65536
    % For single segment mode, auto software avg is ued if averages > 65536
    if params.averages > maxAvg && params.segments > 1
        error(['Max number of averages is ', num2str(maxAvg)]);
    end
    % NbrSamples must be multiple of 16
    NbrSamples = ceil(params.samples/16)*16;
    if (NbrSamples * params.segments > 2^21)
        error('Make sure samples * segments <= 2^21')
    end
    for channel = 1:2
        status = AqD1_configAvgConfigInt32(self.instrID, channel, 'NbrSamples', ...
                                           NbrSamples);
        if status ~= 0
            error('Error setting nbrSamples');
        end
        status = AqD1_configAvgConfigInt32(self.instrID, channel, 'NbrRoundRobins', ...
                                           NbrRoundRobins);                                      
        if status ~= 0
            error('Error setting nbrAverages');
        end
        status = AqD1_configAvgConfigInt32(self.instrID, channel, 'NbrSegments', ...
                                           params.segments);
        if status ~= 0
            error('Error setting nbrSegments');
        end
        AqD1_configAvgConfigInt32(self.instrID, channel, 'DitherRange',0);
        AqD1_configAvgConfigInt32(self.instrID, channel, 'NbrWaveforms', 1);
        AqD1_configAvgConfigInt32(self.instrID, channel, 'TrigResync', 0);
    end
    % Set up AqReadParameters for readIandQ
    self.AqReadParameters.DelaySamples = StartDelay;
    self.AqReadParameters.dataType = 3; % 3 = 64 bit real, 2 = 32 bit int
    self.AqReadParameters.readMode = 2; % 2 = averaged waveform
    self.AqReadParameters.firstSegment = 0;
    self.AqReadParameters.nbrSegments = params.segments;
    self.AqReadParameters.firstSampleInSeg = 0;
    self.AqReadParameters.nbrSamplesInSeg = NbrSamples;
    self.AqReadParameters.segmentOffset = NbrSamples;
    self.AqReadParameters.dataArraySize = (NbrSamples+32)*params.segments*8; % in bytes, 32 bit int is 4 bytes
    self.AqReadParameters.segDescArraySize = 40*params.segments;
    self.AqReadParameters.flags = 0;
    self.AqReadParameters.reserved = 0;
    self.AqReadParameters.reserved2 = 0;
    self.AqReadParameters.reserved3 = 0;
    self.AqReadParameters.timeOut = params.timeout;
    self.AqReadParameters.softAvg = softAvg;
end