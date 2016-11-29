function [Idata, Isqdata, Qdata, Qsqdata] = ReadIandQcomplicated(self)
% Perform acquisition for ChI and ChQ with background substraction
% Output <Is-Iback>,<(Is-Iback)^2> 

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
    [IdataArray, ~, IactualPoints, IfirstValidPoint, ~, ~, ~, ~] ...
     = device.Channels.Item(params.ChI).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, IdataArray);
    
    % Fetch Qdata
    [QdataArray, ~, QactualPoints, QfirstValidPoint, ~, ~, ~, ~] ...
     = device.Channels.Item(params.ChQ).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, IdataArray);
    
    device.Acquisition.Abort();
 
    % Rearrange each single shot experiment in every column
    segsize = IfirstValidPoint(2)-IfirstValidPoint(1);
    tempI = reshape(IdataArray, segsize, params.segments*params.averages);
    clear IdataArray;
    % Subtract background(even index) from signal(odd index)
    tempI = tempI(:, 1:2:end) - tempI(:, 2:2:end);
    % Average all single shot (Is-Iback) and (Is-Iback)^2
    % and arrange all averaged experiments in every row
    tempIavg = reshape(mean(reshape(tempI, segsize*params.segments/2, params.averages),...
                            2), ...
                       segsize, params.segments/2)';

    tempI2avg = reshape(mean(reshape(tempI.^2, segsize*params.segments/2, params.averages),...
                             2), ...
                        segsize, params.segments/2)';
    clear tempI;
    % remove zero entries
    Idata = tempIavg(:, IfirstValidPoint(1)+1:IactualPoints(1));
    Isqdata = tempI2avg(:, IfirstValidPoint(1)+1:IactualPoints(1));
    clear tempIavg;
    clear tempI2avg;
    
    % Rearrange each single shot experiment in every column
    segsize = QfirstValidPoint(2)-QfirstValidPoint(1);
    tempQ = reshape(QdataArray, segsize, params.segments*params.averages);
    clear QdataArray;
    % Subtract background(even index) from signal(odd index)
    tempQ = tempQ(:, 1:2:end) - tempQ(:, 2:2:end);
    % Average all single shot (Is-Iback) and (Is-Iback)^2
    % and arrange all averaged experiments in every row
    tempQavg = reshape(mean(reshape(tempQ, segsize*params.segments/2, params.averages),...
                            2), ...
                       segsize, params.segments/2)';

    tempQ2avg = reshape(mean(reshape(tempQ.^2, segsize*params.segments/2, params.averages),...
                             2), ...
                        segsize, params.segments/2)';
    clear tempQ;
    % remove zero entries
    Qdata = tempQavg(:, QfirstValidPoint(1)+1:QactualPoints(1));
    Qsqdata = tempQ2avg(:, QfirstValidPoint(1)+1:QactualPoints(1));
    clear tempQavg;
    clear tempQ2avg;

    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end