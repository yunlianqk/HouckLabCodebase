% Returns the (external) clock parameters of the digitizer
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getExtClock.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status clockType inputThreshold delayNbrSamples inputFrequency sampFrequency]= AqD1_getExtClock(instrumentID)
[status clockType inputThreshold delayNbrSamples inputFrequency sampFrequency]= AqDrvMex('AqD1_getExtClock', instrumentID);
