% Returns after acquisition has terminated or after timeout, whichever comes first.
% 'timeout' is in milliseconds. For protection, 'timeout' is internally clipped to a
% range of [0, 10000] milliseconds.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_waitForEndOfAcquisition.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = Aq_waitForEndOfAcquisition(instrumentID, timeOut)
warning ('Deprecated function. Please use AqD1_waitForEndOfAcquisition function')
[status ] = AqDrvMex('AqD1_waitForEndOfAcquisition', instrumentID, timeOut);
