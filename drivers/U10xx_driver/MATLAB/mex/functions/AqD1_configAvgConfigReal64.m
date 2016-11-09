% Configures Averagers and Analyzer (APxxx)!
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_configAvgConfigReal64.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqD1_configAvgConfigReal64(instrumentID, channel, parameterString, value)
[status ] = AqDrvMex('AqD1_configAvgConfigReal64', instrumentID, channel, parameterString, value);
