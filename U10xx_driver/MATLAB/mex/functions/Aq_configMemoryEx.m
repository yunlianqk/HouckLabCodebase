% Configures the memory control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configMemoryEx.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configMemoryEx(instrumentID, nbrSamplesHi, nbrSamplesLo, nbrSegments, nbrBanks, flags)
warning ('Deprecated function. Please use AqD1_configMemoryEx function')
[status] = AqDrvMex('AqD1_configMemoryEx', instrumentID, nbrSamplesHi, nbrSamplesLo, nbrSegments, nbrBanks, flags);
