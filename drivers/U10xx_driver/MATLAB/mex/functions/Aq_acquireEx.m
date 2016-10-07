% Starts an acquisition.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_acquireEx.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_acquireEx(instrumentID, acquireMode, acquireFlags, acquireParams, reserved)
warning ('Deprecated function. Please use AqD1_acquireEx function')
[status] = AqDrvMex('AqD1_acquireEx', instrumentID, acquireMode, acquireFlags, acquireParams, reserved);
