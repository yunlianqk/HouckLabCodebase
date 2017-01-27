function [Idata,Qdata,I2data,Q2data]=Read4ChannelIandQ(self,awg,PlayList)
% Perform acquisition for ChI,ChQ,ChI2,ChQ2
% Additional inputs required to sync with the awg sequence
      
    
    params = self.params;  % Get params all at once
                           % avoid using self.params below because it will
                           % call self.GetParams() and waste time
    device = self.instrID.DeviceSpecific;  % Get device handle
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    % Acquire data
    
    if exist('awg','var')
        if exist('PlayList','var')
            awg.SeqStop(PlayList);
        end
    end
    
    device.Acquisition.Initiate();
    timeoutInMs = (params.averages*params.segments*params.trigPeriod + 1)*1000;%NO MORE THAN 10 SECONDS
    if exist('awg','var')
        if exist('PlayList','var')
            awg.SeqRun(PlayList);
        else
            display('No sequence PlayList input')
        end
    else
        display('No awg input');
    end
    
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
    
     % Fetch I2data
    [I2dataArrayReal64, I2actualRecords, I2actualPoints, I2firstValidPoint, I2initialXOffset, I2initialXTimeSeconds, I2initialXTimeFraction, I2xIncrement] ...
     = device.Channels.Item('Channel3').MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, inArray);
    
    % Fetch Q2data
    [Q2dataArrayReal64, Q2actualRecords, Q2actualPoints, Q2firstValidPoint, Q2initialXOffset, Q2initialXTimeSeconds, Q2initialXTimeFraction, Q2xIncrement] ...
     = device.Channels.Item('Channel4').MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, inArray);
    
 
    % Averaged sequence of segments
    % average all traces in one sequence
    if IactualRecords ~= 1
        tempdataI = sum(reshape(IdataArrayReal64, ...
                                params.segments*(IfirstValidPoint(2)-IfirstValidPoint(1)), ...
                                params.averages), ...
                        2);
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
    
    if I2actualRecords ~= 1
        tempdataI2 = sum(reshape(I2dataArrayReal64, ...
                                params.segments*(I2firstValidPoint(2)-I2firstValidPoint(1)), ...
                                params.averages), ...
                        2);
        clear I2dataArrayReal64;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigI2 = reshape(tempdataI2, I2firstValidPoint(2)-I2firstValidPoint(1), params.segments)';
        clear tempdataI2;
    else
        tempSeqSigI2 = I2dataArrayReal64;
    end
    % remove zero entries
    I2data = tempSeqSigI2(:, I2firstValidPoint(1)+1:I2actualPoints(1));
    clear tempSeqSigI2;

    if QactualRecords ~= 1
        tempdataQ = sum(reshape(QdataArrayReal64, ...
                                params.segments*(QfirstValidPoint(2)-QfirstValidPoint(1)), ...
                                params.averages), ...
                        2);
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
    
    if Q2actualRecords ~= 1
        tempdataQ2 = sum(reshape(Q2dataArrayReal64, ...
                                params.segments*(Q2firstValidPoint(2)-Q2firstValidPoint(1)), ...
                                params.averages), ...
                        2);
        clear Q2dataArrayReal64;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigQ2 = reshape(tempdataQ2, Q2firstValidPoint(2)-Q2firstValidPoint(1), params.segments)';
        clear tempdataQ2;
    else
        tempSeqSigQ2 = Q2dataArrayReal64;
    end
    % remove zero entries
    Q2data = tempSeqSigQ2(:, Q2firstValidPoint(1)+1:Q2actualPoints(1));
    clear tempSeqSigQ2;
    
    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    if exist('awg','var')
        if exist('PlayList','var')
            awg.SeqStop(PlayList);
        end
    end
    
end