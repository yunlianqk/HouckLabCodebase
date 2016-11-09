% Configures the acquisiton conditions of the Time Counter
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: AqT3_configAcqConditions.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqT3_configAcqConditions(instrumentID, timeout, flags, reserved)
[status] = AqDrvMex('AqT3_configAcqConditions', instrumentID, timeout, flags, reserved);
