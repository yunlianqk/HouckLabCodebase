function [Idata,Isqdata,Qdata,Qsqdata]=ReadIandQcomplicated(self,awg,PlayList)
% Perform acquisition for ChI and ChQ with background substraction
% Output <Is-Iback>,<(Is-Iback)^2> 
% Additional inputs required to sync with the awg sequence
 
      
    
    params = self.params;  % Get params all at once
                           % avoid using self.params below because it will
                           % call self.GetParams() and waste time
    device = self.instrID.DeviceSpecific;  % Get device handle
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    % Acquire data
    
    % Before initiating aquisition...
    % Make sure awg is not sending marker trigger to the card
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
    
    if IactualRecords ~= 1
        % Rearrange each single shot experiment in every column
        tempI = reshape(IdataArrayReal64,...
            (IfirstValidPoint(2)-IfirstValidPoint(1)),...
            params.segments*params.averages);
        
        % Subtract background(even index) from signal(odd index)
        tempIsub=zeros((IfirstValidPoint(2)-IfirstValidPoint(1)),params.segments*params.averages/2);
        for index=1:(params.segments*params.averages)/2
            tempIsub(:,index)=tempI(:,2*index-1)-tempI(:,2*index);
        end
        clear tempI;
        
        % Average all single shot (Is-Iback) and (Is-Iback)^2
        % and arrange all averaged experiments in every row
        tempIavg = reshape(sum(reshape(tempIsub,...
                    (IfirstValidPoint(2)-IfirstValidPoint(1))*params.segments/2,params.averages),...
                    2),(IfirstValidPoint(2)-IfirstValidPoint(1)),params.segments/2)';
                
        tempI2avg = reshape(sum(reshape(tempIsub.^2,...
                    (IfirstValidPoint(2)-IfirstValidPoint(1))*params.segments/2,params.averages),...
                    2),(IfirstValidPoint(2)-IfirstValidPoint(1)),params.segments/2)';
        clear tempIsub;
    else
        tempIavg = IdataArrayReal64;
        tempI2avg = IdataArrayReal64.^2;
    end
    
    % remove zero entries
    Idata=tempIavg(:, IfirstValidPoint(1)+1:IactualPoints(1))./params.averages;
    Isqdata=tempI2avg(:, IfirstValidPoint(1)+1:IactualPoints(1))./params.averages;
    clear tempIavg;
    clear tempI2avg;
    
    if QactualRecords ~= 1
        % Rearrange each single shot experiment in every column
        tempQ = reshape(QdataArrayReal64,...
            (QfirstValidPoint(2)-QfirstValidPoint(1)),...
            params.segments*params.averages);
        
        % Subtract background(even index) from signal(odd index)
        tempQsub=zeros((QfirstValidPoint(2)-QfirstValidPoint(1)),params.segments*params.averages/2);
        for index=1:(params.segments*params.averages)/2
            tempQsub(:,index)=tempQ(:,2*index-1)-tempQ(:,2*index);
        end
        clear tempQ;
        
        % Average all single shot (Is-Iback) and (Is-Iback)^2
        % and arrange all averaged experiments in every row
        tempQavg = reshape(sum(reshape(tempQsub,...
                    (QfirstValidPoint(2)-QfirstValidPoint(1))*params.segments/2,params.averages),...
                    2),(QfirstValidPoint(2)-QfirstValidPoint(1)),params.segments/2)';
                
        tempQ2avg = reshape(sum(reshape(tempQsub.^2,...
                    (QfirstValidPoint(2)-QfirstValidPoint(1))*params.segments/2,params.averages),...
                    2),(QfirstValidPoint(2)-QfirstValidPoint(1)),params.segments/2)';
        clear tempQsub;
    else
        tempQavg = QdataArrayReal64;
        tempQ2avg = QdataArrayReal64.^2;
    end
    
    % remove zero entries
    Qdata=tempQavg(:, QfirstValidPoint(1)+1:QactualPoints(1))./params.averages;
    Qsqdata=tempQ2avg(:, QfirstValidPoint(1)+1:QactualPoints(1))./params.averages;
    clear tempQavg;
    clear tempQ2avg;
    
    

    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    
    if exist('awg','var')
        if exist('PlayList','var')
            awg.SeqStop(PlayList);
        end
    end
    
end