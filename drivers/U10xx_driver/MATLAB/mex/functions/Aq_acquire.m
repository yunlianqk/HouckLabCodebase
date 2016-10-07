% Starts an acquisition. This function is equivalent to 'acquireEx' with 'acquireMode = 0, 
% acquireFlags = 0'
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_acquire.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_acquire(instrumentID)
warning ('Deprecated function. Please use AqD1_acquire function')
[status] = AqDrvMex('AqD1_acquire', instrumentID);
