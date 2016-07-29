function [Idata,Qdata]=ReadIandQ(self)
% Perform acquisition for ChI and ChQ
      
    
    params = self.params;  % Get params all at once
                           % avoid using self.params below because it will
                           % call self.GetParams() and waste time
    device = self.instrID.DeviceSpecific;  % Get device handle
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    % Acquire data
    device.Acquisition.Initiate();
    timeoutInMs = (params.averages*params.segments*params.trigPeriod + 1)*1000;%NO MORE THAN 10 SECONDS
    try
        device.Acquisition.WaitForAcquisitionComplete(timeoutInMs);
    catch
        disp('No valid trigger...force manual triggers.');
    end
    
    % Buffer array
    arraySize = device.Acquisition.QueryMinWaveformMemory(64,...
        params.averages*params.segments, 0, params.samples);
    inArray = double(zeros(arraySize,1));
    
    % Fetch Idata
    [IdataArrayReal64, IactualRecords, IactualPoints, IfirstValidPoint, IinitialXOffset, IinitialXTimeSeconds, IinitialXTimeFraction, IxIncrement] ...
     = device.Channels.Item(params.ChI).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, inArray);
    
    % Fetch Qdata
    [QdataArrayReal64, QactualRecords, QactualPoints, QfirstValidPoint, QinitialXOffset, QinitialXTimeSeconds, QinitialXTimeFraction, QxIncrement] ...
     = device.Channels.Item(params.ChQ).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, inArray);
    
    % Averaged sequence of segments
    % average all traces in one sequence
    if IactualRecords ~= 1
        tempdataI = sum(reshape(IdataArrayReal64, ...
                                params.segments*(IfirstValidPoint(2)-IfirstValidPoint(1)), ...
                                params.averages), ...
                        2)/params.averages;
        clear IdataArrayReal64;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigI = reshape(tempdataI, IfirstValidPoint(2)-IfirstValidPoint(1), params.segments)';
        clear tempdataI;
    else
        tempSeqSigI = IdataArrayReal64;
    end
    % remove zero entries
    Idata = tempSeqSigI(:, IfirstValidPoint(1)+1:IactualPoints(1));
    clear tempSeqSigI;

    if QactualRecords ~= 1
        tempdataQ = sum(reshape(QdataArrayReal64, ...
                                params.segments*(QfirstValidPoint(2)-QfirstValidPoint(1)), ...
                                params.averages), ...
                        2)/params.averages;
        clear QdataArrayReal64;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigQ = reshape(tempdataQ, QfirstValidPoint(2)-QfirstValidPoint(1), params.segments)';
        clear tempdataQ;
    else
        tempSeqSigQ = QdataArrayReal64;
    end
    % remove zero entries
    Qdata = tempSeqSigQ(:, QfirstValidPoint(1)+1:QactualPoints(1));
    clear tempSeqSigQ;
    
    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end