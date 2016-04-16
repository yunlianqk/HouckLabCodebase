function SetParams(card, params)
% Set card parameters
    
    % Vertical settings
    Vertoffset = 0;
    Vertbandwidth = 0; % 5= 35 MHz LPF
    if (strcmp(params.couplemode,'AC'))
        Vertcoupling = 4; % 4 = AC coupled, 50 Ohm
    else
        Vertcoupling = 3; % 3 = DC coupled, 50 Ohm
    end
    for channel = 1:2
        status = AqD1_configVertical(card.instrID, channel, params.fullscale, ...
                                     Vertoffset, Vertcoupling, Vertbandwidth);
        if status ~= 0
            error('Error in vertical settings');
        end
    end
    % Horizontal settings
    status = AqD1_configHorizontal(card.instrID, params.sampleinterval, params.delaytime);
    if status ~= 0
        error('Error in horizontal settings');
    end
    % configure the delay parameters
    % delaytime as configured by confighorsettings is ignored
    StartDelay = params.delaytime/params.sampleinterval;
    StartDelay = floor(StartDelay/16)*16;
    for channel = 1:2
        status = AqD1_configAvgConfigInt32(card.instrID, channel, 'StartDelay', StartDelay);
        if status ~= 0
            error('Error setting delay time');
        end
    end
    % Memory settings
    status = AqD1_configMemory(card.instrID, params.samples, params.segments);
    if status ~= 0
        error('Error in memory settings');
    end
    % Averaging settings
    NumRoundRobins = 1;
    NumDitherRange = 0;
    NumTrigResync = 0;
    for channel = 1:2
        status = AqD1_configAvgConfigInt32(card.instrID, channel, 'NbrSamples', ...
                                           params.samples);
        if status ~= 0
            error('Error setting nbrSamples');
        end
        status = AqD1_configAvgConfigInt32(card.instrID, channel, 'NbrWaveforms', ...
                                           params.averages);
        if status ~= 0
            error('Error setting nbrWaveforms');
        end
        status = AqD1_configAvgConfigInt32(card.instrID, channel, 'NbrSegments', ...
                                           params.segments);
        if status ~= 0
            error('Error setting nbrSegments');
        end
        AqD1_configAvgConfigInt32(card.instrID, channel, 'DitherRange', NumDitherRange);
        AqD1_configAvgConfigInt32(card.instrID, channel, 'NbrRoundRobins', NumRoundRobins);
        AqD1_configAvgConfigInt32(card.instrID, channel, 'TrigResync', NumTrigResync);
    end
    % Set up AqReadParameters for readIandQ
    card.AqReadParameters.DelaySamples = StartDelay;
    card.AqReadParameters.dataType = 3; % 3 = 64 bit real, 2 = 32 bit int
    card.AqReadParameters.readMode = 2; % 2 = averaged waveform
    card.AqReadParameters.firstSegment = 0;
    card.AqReadParameters.nbrSegments = params.segments;
    card.AqReadParameters.firstSampleInSeg = 0;
    card.AqReadParameters.nbrSamplesInSeg = params.samples;
    card.AqReadParameters.segmentOffset = params.samples;
    card.AqReadParameters.dataArraySize = (params.samples+32)*params.segments*8; % in bytes, 32 bit int is 4 bytes
    card.AqReadParameters.segDescArraySize = 40*params.segments;
    card.AqReadParameters.flags = 0;
    card.AqReadParameters.reserved = 0;
    card.AqReadParameters.reserved2 = 0;
    card.AqReadParameters.reserved3 = 0;
end