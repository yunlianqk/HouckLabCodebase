% 'Manually' combines a number of digitizers into a single "MultiInstrument"
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_multiInstrDefine.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status instrumentID] = Aq_multiInstrDefine(instrumentList, nbrInstruments, masterID)
warning ('Deprecated function. Please use AqD1_multiInstrDefine function')
[status instrumentID] = AqDrvMex('AqD1_multiInstrDefine', instrumentList, nbrInstruments, masterID);
