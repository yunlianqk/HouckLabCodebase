function dataArray = ReadChannels64_multiSegment(self, chList)
% Read the channels specified by chList

params = self.params;  % Get params all at once
% avoid using self.params below because it will
% call self.GetParams() and waste time


device = self.instrID;

warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');

% Save origin channel settings
channelList={'Channel1', 'Channel2', 'Channel3', 'Channel4',...
    'Channel5', 'Channel6', 'Channel7', 'Channel8'};

% Check channel list
if min(chList) < 1 || max(chList) > 8
    display('Error: channel number needs to be between 1 and 8');
    return;
end
if ~isequal(chList, unique(chList))
    display('Warning: duplicate channel numbers in chList');
end


if strcmp(params.couplemode, 'DC')
    coupling = 1;
elseif strcmp(params.coupledmode, 'AC')
    coupling = 0;
else
    display('Unknow couplemode');
end

% Enable ChI and ChQ
for ch = 1:8
    pCh = 1:8;
    if ismember(pCh(ch), chList)
        enabled = 1;
    else
        enabled = 0;
    end
    %         pCh.Configure(params.fullscale, params.offset, coupling, enabled);
    invoke(device.Configurationchannel, 'configurechannel', channelList{ch},...
        params.fullscale, params.offset, coupling, enabled);
end

% Set the acquisition parameters
invoke(device.Configurationacquisition, 'configureacquisition',...
    1, params.samples, params.samplerate);

%Size waveform arrays as required
arraySize =...
    invoke(device.Waveformacquisitionlowlevelacquisition,...
    'queryminwaveformmemory',64,params.averages*params.segments,0,params.samples);

inArray = zeros(arraySize,1,'double');
dataArray = zeros(length(chList), params.segments, params.samples);

%     disp('Measuring ...');

% Initialize the acquisition
invoke(device.Waveformacquisitionlowlevelacquisition,...
    'initiateacquisition');

% Set the trigger source, and trigger type
invoke(device.Configurationtrigger,'configureedgetriggersource',...
    params.trigSource, params.trigLevel, 1);

% Wait for maximum 1 second for the acquisition to complete,
try
    invoke(device.Waveformacquisitionlowlevelacquisition,...
        'waitforacquisitioncomplete', 1500);
catch exception
    % if there is no trigger, send a software trigger
    invoke(device.Waveformacquisitionlowlevelacquisition,...
        'sendsoftwaretrigger');
    disp('No trigger detected on module 1, forcing software trigger');
    invoke(device.Waveformacquisitionlowlevelacquisition,...
        'waitforacquisitioncomplete', 1500);
end

% % Fetch the acquisition waveform data
% counter=1;
% for index = 1:8
%     if ismember(pCh(index), chList)
%         [inArray,ActualPoints1,FirstValidPoint1,...
%             InitialXOffset1,InitialXTimeSeconds1,InitialXTimeFraction1,...
%             XIncrement, ScaleFactor, ScaleOffset] = ...
%             invoke(device.Waveformacquisitionlowlevelacquisitionmultirecordacquisition,...
%             'fetchwaveformint16',channelList{index},arraySize,inArray);
%         
%         % Convert data to Volts.
%         for i=1+FirstValidPoint1:FirstValidPoint1+ActualPoints1
%             inArray(i) = inArray(i) * ScaleFactor + ScaleOffset;
%         end;
%         
%         dataArray(counter, :) = inArray(1+FirstValidPoint1:FirstValidPoint1+ActualPoints1)';
%         counter=counter+1;
%     end
%     
%     
% end
%     disp('Measurement Complete ...');

    % Fetch data
    for index = 1:length(chList)
        [dataArrayReal64, actualRecords, actualPoints, firstValidPoint, ~, ~, ~, ~] ...
            = invoke(device.Waveformacquisitionlowlevelacquisitionmultirecordacquisition,...
            'fetchmultirecordwaveformreal64',channelList{index}, 1, params.averages*params.segments, 0, params.samples, arraySize, inArray, 0, 0, 0, 0, 1);
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



% Enable ChI and ChQ
for ch = 1:8
    pCh = 1:8;
    if ismember(pCh(ch), [1 2])
        enabled = 1;
    else
        enabled = 0;
    end
    %         pCh.Configure(params.fullscale, params.offset, coupling, enabled);
    invoke(device.Configurationchannel, 'configurechannel', channelList{ch},...
        params.fullscale, params.offset, coupling, enabled);
end

end
