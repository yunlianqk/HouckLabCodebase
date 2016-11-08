% Returns the current memory control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getMemoryEx.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status  nbrSamplesHi nbrSamplesLo nbrSegments nbrBanks flags]= Aq_getMemoryEx(instrumentID)
warning ('Deprecated function. Please use AqD1_getMemoryEx function')
[status  nbrSamplesHi nbrSamplesLo nbrSegments nbrBanks flags] = AqDrvMex('AqD1_getMemoryEx', instrumentID);
