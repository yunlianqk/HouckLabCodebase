function [IData, QData] = ReadIandQ(self)
% Acquire data from two channels

    MaxTimeout = 10;  % Maximum single timeout is 10 seconds, hardware coded
    % Stop any ongoing acquistion
    AqD1_stopAcquisition(self.instrID);
    % Start a new acquisition
    AqD1_acquire(self.instrID);
    % If card.params.timeout > MaxTimeout, repeatedly "waitForEndOfAcquisition"
    for repeat = 1:ceil(self.AqReadParameters.timeOut/MaxTimeout)
        % This function accepts timeout in milliseconds
        AqD1_waitForEndOfAcquisition(self.instrID, MaxTimeout*1e3);
    end
    % read the channels
    [status, dataDesc, ~, IData] = AqD1_readData(self.instrID, 1, ...
                                                 self.AqReadParameters);
    if status ~= 0
        error('Error reading channel. Make sure trigger is available and timeout is long enough.');
    end
    % read the second chanel
    [~, ~, ~, QData] = AqD1_readData(self.instrID, 2, self.AqReadParameters);
    
    AqD1_stopAcquisition(self.instrID);
    % If software averaging is needed
    if self.AqReadParameters.softAvg > 1
        for avg = 2:self.AqReadParameters.softAvg
                AqD1_stopAcquisition(self.instrID);
                AqD1_acquire(self.instrID);
                for repeat = 1:ceil(self.AqReadParameters.timeOut/MaxTimeout)
                    AqD1_waitForEndOfAcquisition(self.instrID, MaxTimeout*1e3);
                end
                [~, ~, ~, Itemp] = AqD1_readData(self.instrID, 1, ...
                                                 self.AqReadParameters);
                [~, ~, ~, Qtemp] = AqD1_readData(self.instrID, 2, ...
                                                 self.AqReadParameters);
                IData = IData + Itemp;
                QData = QData + Qtemp;
        end
        IData = IData/self.AqReadParameters.softAvg;
        QData = QData/self.AqReadParameters.softAvg;
    end
        
    % truncate the data to contain only relevant points
    samples = self.AqReadParameters.nbrSamplesInSeg;
    segments = self.AqReadParameters.nbrSegments;
    firstPt = dataDesc.indexFirstPoint;

    IData = reshape(IData(firstPt+1:firstPt+samples*segments), samples, segments);
    QData = reshape(QData(firstPt+1:firstPt+samples*segments), samples, segments);
end