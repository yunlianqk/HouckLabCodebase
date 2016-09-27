% Returns the current operational mode of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getMode.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status mode modifiers flags] = AqD1_getMode(instrumentID)
[status mode modifiers flags] = AqDrvMex('AqD1_getMode', instrumentID);
