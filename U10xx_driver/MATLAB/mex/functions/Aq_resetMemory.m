% Resets the device memory to a known default state. 
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_resetMemory.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status]= Aq_resetMemory(instrumentID)
[status] = AqDrvMex('Aq_resetMemory', instrumentID);