% Returns the data acqired by the Time Counter.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: AqT3_readData.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status dataDesc dataArray] = AqT3_readData(instrumentID, channel, readParAnyOrder)
% The MEX parameters are transferred by a memory copy. In the case of a
% structure, we must be sure that we send the elements in the same order as they are read.
try
    readPar = struct(   'dataSizeInBytes', readParAnyOrder.dataSizeInBytes, ...
                        'nbrSamples', readParAnyOrder.nbrSamples, ...
                        'dataType', readParAnyOrder.dataType, ...
                        'readMode', readParAnyOrder.readMode, ...
                        'reserved3', readParAnyOrder.reserved3, ...
                        'reserved2', readParAnyOrder.reserved2, ...
                        'reserved1', readParAnyOrder.reserved1);
catch
    error('Read parameters structure invalid.')
end

[status dataDesc dataArray] = AqDrvMex('AqT3_readData', instrumentID, channel, readPar);
