% 'Manually' combines a number of digitizers into a single "MultiInstrument"
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_multiInstrDefine.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status instrumentID] = AqD1_multiInstrDefine(instrumentList, nbrInstruments, masterID)
[status instrumentID] = AqDrvMex('AqD1_multiInstrDefine', instrumentList, nbrInstruments, masterID);
