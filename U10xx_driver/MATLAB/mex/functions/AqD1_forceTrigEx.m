% Forces a 'manual' trigger. The function returns immediately after initiating
% a trigger. One must therefore wait until this acquisition has terminated
% before reading the data, by checking the status with the 'AcqrsD1_acqDone'
% or the 'AcqrsD1_waitForEndOfAcquisition' functions.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_forceTrigEx.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqD1_forceTrigEx(instrumentID, forceTrigType, modifier, flags)
[status ] = AqDrvMex('AqD1_forceTrigEx', instrumentID, forceTrigType, modifier, flags);
