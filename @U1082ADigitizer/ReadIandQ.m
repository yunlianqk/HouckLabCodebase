function [IData, QData] = ReadIandQ(card)
% Acquire data from two channels
    AcqTimeout = 10000;
    AqD1_stopAcquisition(card.instrID);
    AqD1_acquire(card.instrID);
    AqD1_waitForEndOfAcquisition(card.instrID, AcqTimeout);
    % read the channels
    [status, dataDesc, ~, IData] = AqD1_readData(card.instrID, 1, ...
                                                 card.AqReadParameters);
    if status ~= 0
        error('Error reading channel 1');
    end
    % read the second chanel
    [status, dataDesc, ~, QData] = AqD1_readData(card.instrID, 2, ...
                                                 card.AqReadParameters);
    if status ~= 0
        error('Error reading channel 2');
    end
    % truncate the data to contain only relevant points
    samples = card.AqReadParameters.nbrSamplesInSeg;
    segments = card.AqReadParameters.nbrSegments;
    firstPt = dataDesc.indexFirstPoint;

    IData = reshape(IData(firstPt+1:firstPt+samples*segments), ...
                    samples, segments);
    QData = reshape(QData(firstPt+1:firstPt+samples*segments), ...
                    samples, segments);
end