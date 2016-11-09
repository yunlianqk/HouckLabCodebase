% Gets the operational mode of the Time Counter.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: AqT3_getMode.m 33903 2009-01-26 16:45:39Z bdonnier $

 function [status mode modifiers flags] = AqT3_getMode(instrumentID)
[status mode modifiers flags] = AqDrvMex('AqT3_getMode', instrumentID);
