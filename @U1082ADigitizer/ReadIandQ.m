function [IData, QData] = ReadIandQ(card)
% Acquire data from two channels
    AcqTimeout = 10000;
    status = AqD1_stopAcquisition(card.instrID);
    status = AqD1_acquire(card.instrID);
    status = AqD1_waitForEndOfAcquisition(card.instrID, AcqTimeout);
    % read the first channel
    [status, dataDesc, segDescArray, IData] = AqD1_readData(card.instrID, 1, card.AqReadParameters);
    % read the second chanel
    [status, dataDesc, segDescArray, QData] = AqD1_readData(card.instrID, 2, card.AqReadParameters);
    % truncate the data to contain only relevant points
    totnumsamples = card.samples * card.segments; %total number of relevant points
    firstPt = dataDesc.indexFirstPoint;
    subrange = 1 + firstPt:firstPt + totnumsamples;

    IData = reshape(IData(subrange), card.samples, card.segments);
    QData = reshape(QData(subrange), card.samples, card.segments);
end