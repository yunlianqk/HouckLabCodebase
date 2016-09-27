% Configures the frequency counter
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configFCounter.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configFCounter(instrumentID, signalChannel, typeMes, targetValue, apertureTime, reserved, flags)
warning ('Deprecated function. Please use AqD1_configFCounter function')
[status ] = AqDrvMex('AqD1_configFCounter', instrumentID, signalChannel, typeMes, targetValue, apertureTime, reserved, flags);
