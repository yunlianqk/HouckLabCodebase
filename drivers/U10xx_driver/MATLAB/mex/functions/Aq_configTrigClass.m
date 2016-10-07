% Configures the trigger class control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configTrigClass.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configTrigClass(instrumentID, trigClass, sourcePattern, validatePattern, holdType, holdoffTime, reserved)
warning ('Deprecated function. Please use AqD1_configTrigClass function')
[status ] = AqDrvMex('AqD1_configTrigClass', instrumentID, trigClass, sourcePattern, validatePattern, holdType, holdoffTime, reserved);
