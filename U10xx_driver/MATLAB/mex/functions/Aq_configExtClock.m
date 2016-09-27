% Configures the external clock of the digitizer
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configExtClock.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configExtClock(instrumentID, clockType, inputThreshold, delayNbrSamples, inputFrequency, sampFrequency)
warning ('Deprecated function. Please use AqD1_configExtClock function')
[status ] = AqDrvMex('AqD1_configExtClock', instrumentID, clockType, inputThreshold, delayNbrSamples, inputFrequency, sampFrequency);
