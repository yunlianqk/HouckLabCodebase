function dataArray = Read64_multiSeg(self, channel)
% Read a single channel. 

params = self.params;  % Get params all at once
% avoid using self.params below because it will
% call self.GetParams() and waste time
% tic
device = self.instrID;

warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');

% %AKmod
% numSegments = invoke(self.instrID.Attributeaccessors, 'getattributeviint64',...
%     '', 1250013);
% disp(numSegments)
% params.segments = numSegments;

%Size waveform arrays as required
arraySize = invoke(device.Waveformacquisitionlowlevelacquisition,...
    'queryminwaveformmemory',64,params.averages*params.segments,0,params.samples);

inArray = zeros(arraySize,1,'double');
% toc 
% tic
% Initialize the acquisition  - Do this via card.WaitTrigger() to sync with
% AWG. 
% invoke(device.Waveformacquisitionlowlevelacquisition,...
%     'initiateacquisition');

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
        'waitforacquisitioncomplete', 10);
end
% toc
% Fetch data
inActualPoints = int64(zeros(params.averages*params.segments+1, 1));
inFirstValidPoint = int64(zeros(params.averages*params.segments+1, 1));
inInitialXOffset = double(zeros(params.averages*params.segments+1, 1));
inInitialXTimeSeconds = double(zeros(params.averages*params.segments+1, 1));
inInitialXTimeFraction = double(zeros(params.averages*params.segments+1, 1));

% %AKmod
% inActualPoints = int64(zeros(numSegments+1, 1));
% inFirstValidPoint = int64(zeros(numSegments+1, 1));
% inInitialXOffset = double(zeros(numSegments+1, 1));
% inInitialXTimeSeconds = double(zeros(numSegments+1, 1));
% inInitialXTimeFraction = double(zeros(numSegments+1, 1));

% inActualPoints = int16(zeros(params.averages*params.segments+1, 1));
% inFirstValidPoint = int16(zeros(params.averages*params.segments+1, 1));
% inInitialXOffset = int16(zeros(params.averages*params.segments+1, 1));
% inInitialXTimeSeconds = int16(zeros(params.averages*params.segments+1, 1));
% inInitialXTimeFraction = int16(zeros(params.averages*params.segments+1, 1));
FirstRecord = 0;

disp('Fetch data')
tic
[dataArrayReal64, ~, actualRecords, actualPoints, firstValidPoint, ~, ~, ~, ~] ...
    = invoke(device.Waveformacquisitionlowlevelacquisitionmultirecordacquisition,...
    'fetchmultirecordwaveformreal64', channel, FirstRecord, params.averages*params.segments, 0, ...
    params.samples, arraySize, inArray, inActualPoints, inFirstValidPoint,...
    inInitialXOffset, inInitialXTimeSeconds, inInitialXTimeFraction);
toc
size(dataArrayReal64)
% % Alternate method: using int16 and converting to volts afterwards
% tic
% [dataArrayReal64, ~, actualRecords, actualPoints, firstValidPoint, ~, ~, ~, ~, ScaleFactor, ScaleOffset] ...
%         = invoke(device.Waveformacquisitionlowlevelacquisitionmultirecordacquisition,...
%         'fetchmultirecordwaveformint16', channel, FirstRecord, params.averages*params.segments, 0, ...
%         params.samples, arraySize, inArray, inActualPoints, inFirstValidPoint,...
%         inInitialXOffset, inInitialXTimeSeconds, inInitialXTimeFraction);
% %     Convert to Volts. Alternate: use fetchmultirecordwaveformReal64
%     dataArrayReal64 = dataArrayReal64.*ScaleFactor + ScaleOffset;
%     toc

% disp('reshaping')
% tic
% Averaged sequence of segments
if actualRecords ~= 1
    tempdata = sum(reshape(dataArrayReal64, params.segments*(firstValidPoint(2)-firstValidPoint(1)), ...
        params.averages), ...
        2)/params.averages;
    
    % reshape matrix so final form has each averaged segement in each row
    tempSeqSig = reshape(tempdata, firstValidPoint(2)-firstValidPoint(1), params.segments)';
else
    tempSeqSig = dataArrayReal64;
end

% remove zero entries
dataArray = tempSeqSig(:, firstValidPoint(1)+1:actualPoints(1));
% toc
% disp('Done acq');
clear dataArrayReal64 tempSeqSig actualRecords actualPoints firstValidPoint inArray FirstRecord arraySize
clear tempdata inActualPoints inFirstValidPoint inInitialXOffset inInitialXTimeSeconds inInitialXTimeFraction

end