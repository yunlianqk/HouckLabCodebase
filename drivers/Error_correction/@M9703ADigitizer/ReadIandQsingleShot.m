function [Idata,Qdata]=ReadIandQsingleShot(self,awg,PlayList)
% Perform acquisition for ChI and ChQ for an awg sequence. Return the
% single shot data without averaging.


    params = self.params;  % Get params all at once
    % avoid using self.params below because it will
    % call self.GetParams() and waste time
    %     device = self.instrID.DeviceSpecific;  % Get device handle
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    % Acquire data
    
    % Before initiating aquisition...
    % Make sure awg is not sending marker trigger to the card
    if exist('awg','var')
        if exist('PlayList','var')
            awg.SeqStop(PlayList);
        end
    end

    self.instrID.DeviceSpecific.Acquisition.Initiate();
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
        self.instrID.DeviceSpecific.Acquisition.WaitForAcquisitionComplete(timeoutInMs);
    catch
        disp('No valid trigger...force manual triggers.');
    end
   
    % Buffer array
    arraySize = self.instrID.DeviceSpecific.Acquisition.QueryMinWaveformMemory(64,...
        params.averages*params.segments, 0, params.samples);
%     inArray = double(zeros(arraySize,1));
    inArray = zeros(arraySize,1,'double');
    
    % Fetch Idata
    [IdataArrayReal64, IactualRecords, IactualPoints, IfirstValidPoint, IinitialXOffset, IinitialXTimeSeconds, IinitialXTimeFraction, IxIncrement] ...
     = self.instrID.DeviceSpecific.Channels.Item(params.ChI).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, inArray);
    
    % Fetch Qdata
    [QdataArrayReal64, QactualRecords, QactualPoints, QfirstValidPoint, QinitialXOffset, QinitialXTimeSeconds, QinitialXTimeFraction, QxIncrement] ...
     = self.instrID.DeviceSpecific.Channels.Item(params.ChQ).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,params.averages*params.segments, 0, params.samples, inArray);
%     
%     if IactualRecords ~= 1
%         % Rearrange each single shot experiment in every column
        Idata = reshape(IdataArrayReal64,...
            (IfirstValidPoint(2)-IfirstValidPoint(1)),...
            params.segments*params.averages);
        
        Qdata = reshape(QdataArrayReal64,...
            (QfirstValidPoint(2)-QfirstValidPoint(1)),...
            params.segments*params.averages);
    
    
end
 
