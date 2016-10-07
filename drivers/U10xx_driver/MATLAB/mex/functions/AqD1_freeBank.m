% Free current bank during SMAR acquisitions. Calling this function indicates to the driver that
% the current SMAR bank has been read and can be reused for a new acquisition. 
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_freeBank.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqD1_freeBank(instrumentID, reserved)
[status] = AqDrvMex('AqD1_freeBank', instrumentID, reserved);
