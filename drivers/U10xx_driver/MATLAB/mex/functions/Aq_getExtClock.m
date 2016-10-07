% Returns the (external) clock parameters of the digitizer
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getExtClock.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status clockType inputThreshold delayNbrSamples inputFrequency sampFrequency]= Aq_getExtClock(instrumentID)
warning ('Deprecated function. Please use AqD1_getExtClock function')
[status clockType inputThreshold delayNbrSamples inputFrequency sampFrequency]= AqDrvMex('AqD1_getExtClock', instrumentID);
