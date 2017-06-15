function [IData, QData] = ReadIandQ(self)
% Acquire data from two channels
    MaxTimeout = 10;  % Maximum single timeout is 10 seconds, hardware coded
    params = self.params;
    if params.trigPeriod < params.delaytime+params.samples*params.sampleinterval
        display('Warning: trigger period is shorter than delay + acquisition time');
        display(['Set trigge period to more than ', ...
                  num2str((params.delaytime+params.samples*params.sampleinterval)/1e-6), ...
                  ' us']);
    end
    if self.waittrig
        % If in "wait trigger" mode, acquisition already started
        % Only need to wait for end of acquisition
        for repeat = 1:ceil(self.AqReadParameters.timeOut/MaxTimeout)
            AqD1_waitForEndOfAcquisition(self.instrID, MaxTimeout*1e3);
        end
        [status, dataDesc, ~, IData] ...
            = AqD1_readData(self.instrID, 1,  self.AqReadParameters);
        if status  < 0
            error(['Error reading channel. Make sure trigger is available ', ...
                   'and trigger period is set correctly.']);
        end
        [~, ~, ~, QData] = AqD1_readData(self.instrID, 2, self.AqReadParameters);
        self.waittrig = 0;
    else
        % If in normal mode, stop acquistion and then start it
        IData = 0;
        QData = 0;
        for avg = 1:self.AqReadParameters.softAvg
            AqD1_stopAcquisition(self.instrID);
            AqD1_acquire(self.instrID);
            for repeat = 1:ceil(self.AqReadParameters.timeOut/MaxTimeout)
                AqD1_waitForEndOfAcquisition(self.instrID, MaxTimeout*1e3);
            end
            [status, dataDesc, ~, Itemp] ...
                = AqD1_readData(self.instrID, 1,  self.AqReadParameters);
            if status  < 0
                error(['Error reading channel. Make sure trigger is available ', ...
                       'and trigger period is set correctly.']);
            end
            [~, ~, ~, Qtemp] = AqD1_readData(self.instrID, 2, self.AqReadParameters);
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

    IData = reshape(IData(firstPt+1:firstPt+samples*segments), samples, segments)';
    QData = reshape(QData(firstPt+1:firstPt+samples*segments), samples, segments)';
end