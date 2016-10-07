% Configures the trigger source control parameters for a specified channel in the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configTrigSource.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configTrigSource(instrumentID, channel, trigCoupling, trigSlope, trigLevel1, trigLevel2)
warning ('Deprecated function. Please use AqD1_configTrigSource function')
[status ] = AqDrvMex('AqD1_configTrigSource', instrumentID, channel, trigCoupling, trigSlope, trigLevel1, trigLevel2);
