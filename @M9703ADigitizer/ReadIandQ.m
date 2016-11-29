function [Idata,Qdata] = ReadIandQ(self)
% Perform acquisition for ChI and ChQ
    
    params = self.params;  % Get params all at once
                           % avoid using self.params below because it will
                           % call self.GetParams() and waste time
    device = self.instrID.DeviceSpecific;  % Get device handle
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    % Acquire data
    if ~self.waittrig
        device.Acquisition.Abort();
        device.Acquisition.Initiate();
    end
    timeoutInMs = (params.averages*params.segments*params.trigPeriod + 1)*1000;%NO MORE THAN 10 SECONDS

    try
        device.Acquisition.WaitForAcquisitionComplete(timeoutInMs);
    catch
        disp('No valid trigger...force manual triggers.');
    end
    self.waittrig = 0;
    
    % Buffer array
    arraySize = device.Acquisition.QueryMinWaveformMemory(64,...
        params.averages*params.segments, 0, params.samples);
    IdataArray = zeros(arraySize, 1, 'double');
    
    % Fetch Idata
    [IdataArray, IactualRecords, IactualPoints, IfirstValidPoint, ~, ~, ~, ~] ...
     = device.Channels.Item(params.ChI).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, IdataArray);
    
    % Fetch Qdata
    [QdataArray, QactualRecords, QactualPoints, QfirstValidPoint, ~, ~, ~, ~] ...
     = device.Channels.Item(params.ChQ).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, IdataArray);
 
    device.Acquisition.Abort();
    
    % Averaged sequence of segments
    % average all traces in one sequence
    if IactualRecords ~= 1
        tempdataI = mean(reshape(IdataArray, ...
                                 params.segments*(IfirstValidPoint(2)-IfirstValidPoint(1)), ...
                                 params.averages), 2);
        clear IdataArray;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigI = reshape(tempdataI, IfirstValidPoint(2)-IfirstValidPoint(1), params.segments)';
        clear tempdataI;
    else
        tempSeqSigI = IdataArray;
        clear IdataArray;
    end
    % remove zero entries
    Idata = tempSeqSigI(:, IfirstValidPoint(1)+1:IactualPoints(1));
    clear tempSeqSigI;

    if QactualRecords ~= 1
        tempdataQ = mean(reshape(QdataArray, ...
                                 params.segments*(QfirstValidPoint(2)-QfirstValidPoint(1)), ...
                                 params.averages), 2);
        clear QdataArray;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigQ = reshape(tempdataQ, QfirstValidPoint(2)-QfirstValidPoint(1), params.segments)';
        clear tempdataQ;
    else
        tempSeqSigQ = QdataArray;
        clear QdataArray;
    end
    % remove zero entries
    Qdata = tempSeqSigQ(:, QfirstValidPoint(1)+1:QactualPoints(1));
    clear tempSeqSigQ;
    
    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end