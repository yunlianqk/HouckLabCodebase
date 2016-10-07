% Returns after on-board processing has terminated or after timeout, whichever comes first.
% 'timeout' is in milliseconds. For protection, 'timeout' is internally clipped to a
% range of [0, 10000] milliseconds. (only in instruments with on-board data processing)
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_waitForEndOfProcessing.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = AqD1_waitForEndOfProcessing(instrumentID, timeOut)
[status ] = AqDrvMex('AqD1_waitForEndOfProcessing', instrumentID, timeOut);
