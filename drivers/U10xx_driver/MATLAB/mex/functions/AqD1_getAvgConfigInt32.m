% Returns a parameter from the averager/analyzer configuration
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getAvgConfigInt32.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status value]= AqD1_getAvgConfigInt32(instrumentID, channel, parameterString)
[status value] = AqDrvMex('AqD1_getAvgConfigInt32', instrumentID, channel, parameterString);