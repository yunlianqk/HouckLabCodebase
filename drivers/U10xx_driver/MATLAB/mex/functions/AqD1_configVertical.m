% Configures the vertical control parameters for a specified channel in the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_configVertical.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqD1_configVertical(instrumentID, channel, fullScale, offset, coupling, bandwidth)
[status ] = AqDrvMex('AqD1_configVertical', instrumentID, channel, fullScale, offset, coupling, bandwidth);
