% Free current bank during SMAR acquisitions. Calling this function indicates to the driver that
% the current SMAR bank has been read and can be reused for a new acquisition. 
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_freeBank.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_freeBank(instrumentID, reserved)
warning ('Deprecated function. Please use AqD1_freeBank function')
[status] = AqDrvMex('AqD1_freeBank', instrumentID, reserved);
