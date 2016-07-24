function [Idata,Qdata]=ReadIandQ(self)
% Perform acquisition for ChI and ChQ
      
    
    params = self.params;  % Get params all at once
                           % avoid using self.params below because it will
                           % call self.GetParams() and waste time
    device = self.instrID.DeviceSpecific;  % Get device handle
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    % Acquire data
    device.Acquisition.Initiate();
    timeoutInMs = params.averages*params.segments*params.trigPeriod + 1000;%NO MORE THAN 10 SECONDS
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
    
    if params.segments==1
    % Averaged single segment
        %Data array is one single row vector
        %Convert to matrix where each column vector is a trace
        IdataArrayReal64_mat=reshape(IdataArrayReal64,[IfirstValidPoint(2)-IfirstValidPoint(1),IactualRecords]);
        QdataArrayReal64_mat=reshape(QdataArrayReal64,[QfirstValidPoint(2)-QfirstValidPoint(1),QactualRecords]);
        clear IdataArrayReal64;
        clear QdataArrayReal64;
        %Average signal=sum column traces/ number of actual records
        Idata=sum(IdataArrayReal64_mat,2)./double(IactualRecords);
        Qdata=sum(QdataArrayReal64_mat,2)./double(QactualRecords);
        clear IdataArrayReal64_mat;
        clear QdataArrayReal64_mat;
        %Get rid of the zero entries
        %This can be avoided if config.PointsPerMeas is a ^ of 2
        Idata=Idata(IfirstValidPoint(1)+1:IactualPoints(1));
        Qdata=Qdata(QfirstValidPoint(1)+1:QactualPoints(1));                                                                                                                                        
    else
    % Averaged sequence of segments
        %Fetch I data
        % average all traces in one sequence
        tempdataI=sum(reshape(IdataArrayReal64,params.segments*(IfirstValidPoint(2)-IfirstValidPoint(1)),params.averages)',1)./params.averages;
        clear IdataArrayReal64;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigI=reshape(tempdataI,IfirstValidPoint(2)-IfirstValidPoint(1),params.segments);
        clear tempdataI;
        % remove zero entries
        Idata=tempSeqSigI(IfirstValidPoint(1)+1:IactualPoints(1),:)';
        clear tempSeqSigI; 
        
        %Fetch Q data
        % average all traces in one sequence
        tempdataQ=sum(reshape(QdataArrayReal64,params.segments*(QfirstValidPoint(2)-QfirstValidPoint(1)),params.averages)',1)./params.averages;
        clear QdataArrayReal64;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigQ=reshape(tempdataQ,QfirstValidPoint(2)-QfirstValidPoint(1),params.segments);
        clear tempdataQ;
        % remove zero entries
        Qdata=tempSeqSigQ(QfirstValidPoint(1)+1:QactualPoints(1),:)';
        clear tempSeqSigQ;
        
    end

    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end