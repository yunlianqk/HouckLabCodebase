% Configures the frequency counter
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_configFCounter.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqD1_configFCounter(instrumentID, signalChannel, typeMes, targetValue, apertureTime, reserved, flags)
[status ] = AqDrvMex('AqD1_configFCounter', instrumentID, signalChannel, typeMes, targetValue, apertureTime, reserved, flags);
