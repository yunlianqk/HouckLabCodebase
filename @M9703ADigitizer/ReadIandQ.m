function [Idata,Qdata]=ReadIandQ(self)
    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');    
    % Perform acquisition
    driver=self.instrID;
    driver.DeviceSpecific.Acquisition.Initiate();
    timeoutInMs=self.params.averages*self.params.TrigPeriod+1000;%NO MORE THAN 10 SECONDS
    try
        driver.DeviceSpecific.Acquisition.WaitForAcquisitionComplete(timeoutInMs);
    catch
        disp('No valid trigger...force manual triggers.');
    end
    
    % Fetch data
    arraySize = driver.DeviceSpecific.Acquisition.QueryMinWaveformMemory(64,...
        self.params.averages, 0, self.params.samples);
    inArray = double(zeros(arraySize,1));%Buffer array
    
    % Fetch Idata
    [IdataArrayReal64, IactualRecords, IactualPoints, IfirstValidPoint, IinitialXOffset, IinitialXTimeSeconds, IinitialXTimeFraction, IxIncrement] ...
     = driver.DeviceSpecific.Channels.Item(self.params.ChI).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,self.params.averages, 0, self.params.samples, inArray);
    
    % Fetch Qdata
    [QdataArrayReal64, QactualRecords, QactualPoints, QfirstValidPoint, QinitialXOffset, QinitialXTimeSeconds, QinitialXTimeFraction, QxIncrement] ...
     = driver.DeviceSpecific.Channels.Item(self.params.ChQ).MultiRecordMeasurement.FetchMultiRecordWaveformReal64(0,self.params.averages, 0, self.params.samples, inArray);
    
    if self.params.segments==1
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
        SeqAvg=self.params.averages/self.params.segments;  % number of times the sequence is run
        %Fetch I data
        % average all traces in one sequence
        tempdataI=sum(reshape(IdataArrayReal64,self.params.segments*(IfirstValidPoint(2)-IfirstValidPoint(1)),SeqAvg)',1)./SeqAvg;
        clear IdataArrayReal64;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigI=reshape(tempdataI,IfirstValidPoint(2)-IfirstValidPoint(1),self.params.segments);
        clear tempdataI;
        % remove zero entries
        Idata=tempSeqSigI(IfirstValidPoint(1)+1:IactualPoints(1),:)';
        clear tempSeqSigI; 
        
        %Fetch Q data
        % average all traces in one sequence
        tempdataQ=sum(reshape(QdataArrayReal64,self.params.segments*(QfirstValidPoint(2)-QfirstValidPoint(1)),SeqAvg)',1)./SeqAvg;
        clear QdataArrayReal64;
        % reshape matrix so final form has each averaged segement in each row
        tempSeqSigQ=reshape(tempdataQ,QfirstValidPoint(2)-QfirstValidPoint(1),self.params.segments);
        clear tempdataQ;
        % remove zero entries
        Qdata=tempSeqSigQ(QfirstValidPoint(1)+1:QactualPoints(1),:)';
        clear tempSeqSigQ;
        
    end

    warning('on', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
end