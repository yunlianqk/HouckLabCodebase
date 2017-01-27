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
%     device = self.instrID.DeviceSpecific;
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
        invoke(self.instrID.Configurationchannel, 'configurechannel', params.ChI,...
            params.fullscale, params.offset, coupling, enabled);
    end
    
    
    
    
    disp('Measuring ...');
    
    % Initialize the acquisition
    invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
        'initiateacquisition');
    
    % Wait for maximum 1 second for the acquisition to complete,
    try
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
            'waitforacquisitioncomplete', 1000);
    catch
        % if there is no trigger, send a software trigger
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
            'sendsoftwaretrigger');
        disp('No trigger detected on module 1, forcing software trigger');
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
            'waitforacquisitioncomplete', 1500);
    end
    
    %Size waveform arrays as required
    arraySize =...
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
        'queryminwaveformmemory',16,1,0,params.samples);
    
    inArray = zeros(arraySize,1);
    
    dataArray = zeros(length(chList), params.segments, params.samples);
    
    
    
    % Fetch data
    for index = 1:length(chList)

    
    [WaveformArrayCh1,ActualPoints1,FirstValidPoint1,...
        InitialXOffset1,InitialXTimeSeconds1,InitialXTimeFraction1,...
        XIncrement, ScaleFactor, ScaleOffset] = ...
        invoke(self.instrID.WaveformAcquisitionLowLevelAcquisition,...
        'fetchwaveformint16',chList(index),arraySize,inArray);
   
%         
%     [WaveformArrayCh1,ActualPoints1,FirstValidPoint1,...
%         InitialXOffset1,InitialXTimeSeconds1,InitialXTimeFraction1,...
%         XIncrement, ScaleFactor, ScaleOffset] = ...
%         invoke(myDigitizer.WaveformAcquisitionLowLevelAcquisition,...
%         'fetchwaveformint16',Input_Channel_1,arrayElements,WaveformArrayCh1);
    
%         [dataArrayReal64, actualRecords, actualPoints, firstValidPoint, ~, ~, ~, ~] ...
%             = device.Channels.Item(device.Channels.Name(chList(index))).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0, params.averages*params.segments, 0, params.samples, inArray);
%         % Averaged sequence of segments
%         if actualRecords ~= 1
%             tempdata = sum(reshape(dataArrayReal64, ...
%                                    params.segments*(firstValidPoint(2)-firstValidPoint(1)), ...
%                                    params.averages), ...
%                            2)/params.averages;
%             reshape matrix so final form has each averaged segement in each row
%             tempSeqSig = reshape(tempdata, firstValidPoint(2)-firstValidPoint(1), params.segments)';
%         else
%             tempSeqSig = dataArrayReal64;
%         end
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