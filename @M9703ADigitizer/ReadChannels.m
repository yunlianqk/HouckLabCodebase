function dataArray = ReadChannels(self, chList)
% Read the channels specified by chList

    params = self.params;  % Get params all at once
                           % avoid using self.params below because it will
                           % call self.GetParams() and waste time
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    % Save origin channel settings                           
    ChI = params.ChI;
    ChQ = params.ChQ;

    % Check channel list
    if min(chList) < 1 || max(chList) > 8
        display('Error: channel number needs to be between 1 and 8');
        return;
    end
    if ~isequal(chList, unique(chList))
        display('Warning: duplicate channel numbers in chList');
    end
    % Enable desired channels
    device = self.instrID.DeviceSpecific;
    if strcmp(params.couplemode, 'DC')
        coupling = 1;
    elseif strcmp(params.coupledmode, 'AC')
        coupling = 0;
    else
        display('Unknow couplemode');
    end
    
    for ch = 1:8
        pCh = device.Channels.Item(device.Channels.Name(ch));
        if ismember(ch, chList)
            enabled = 1;
        else
            enabled = 0;
        end
        pCh.Configure(params.fullscale, params.offset, coupling, enabled);
    end
    
    % Perform acquisition
    device.Acquisition.Initiate();
    timeoutInMs = (params.averages*params.segments*params.trigPeriod+1)*1000;%NO MORE THAN 10 SECONDS
    try
        device.Acquisition.WaitForAcquisitionComplete(timeoutInMs);
    catch
        disp('No valid trigger...force manual triggers.');
    end
    
    % Buffer array
    arraySize = device.Acquisition.QueryMinWaveformMemory(64,...
        params.averages*params.segments, 0, params.samples);
    inArray = double(zeros(arraySize, 1));
    dataArray = zeros(length(chList), params.segments, params.samples);
    
    % Fetch data
    for index = 1:length(chList)
        [dataArrayReal64, actualRecords, actualPoints, firstValidPoint, ~, ~, ~, ~] ...
            = device.Channels.Item(device.Channels.Name(chList(index))).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0, params.averages*params.segments, 0, params.samples, inArray);
        % Averaged sequence of segments
        if actualRecords ~= 1
            tempdata = sum(reshape(dataArrayReal64, ...
                                   params.segments*(firstValidPoint(2)-firstValidPoint(1)), ...
                                   params.averages), ...
                           2)/params.averages;
            % reshape matrix so final form has each averaged segement in each row
            tempSeqSig = reshape(tempdata, firstValidPoint(2)-firstValidPoint(1), params.segments)';
        else
            tempSeqSig = dataArrayReal64;
        end
        % remove zero entries
        dataArray(index, :, :) = tempSeqSig(:, firstValidPoint(1)+1:actualPoints(1));
        clear dataArrayReal64;
        clear tempdata;
        clear tempSeqSig;
    end
    dataArray = squeeze(dataArray);
    
    % Revert original channel settings
    for ch = 1:8
        pCh = device.Channels.Item(device.Channels.Name(ch));
        if (strcmp(ChI, device.Channels.Name(ch)) || ...
            strcmp(ChQ, device.Channels.Name(ch)))
            enabled = 1;
        else
            enabled = 0;
        end
        pCh.Configure(params.fullscale, params.offset, coupling, enabled);
    end
    
    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end