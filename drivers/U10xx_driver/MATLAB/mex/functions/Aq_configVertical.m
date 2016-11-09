% Configures the vertical control parameters for a specified channel in the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configVertical.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configVertical(instrumentID, channel, fullScale, offset, coupling, bandwidth)
warning ('Deprecated function. Please use AqD1_configVertical function')
[status ] = AqDrvMex('AqD1_configVertical', instrumentID, channel, fullScale, offset, coupling, bandwidth);
