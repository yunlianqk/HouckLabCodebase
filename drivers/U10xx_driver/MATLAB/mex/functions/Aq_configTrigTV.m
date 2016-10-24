% Configures the TV trigger control parameters for a specified channel in the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configTrigTV.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configTrigTV(instrumentID, channel, standard, field, line)
warning ('Deprecated function. Please use AqD1_configTrigTV function')
[status ] = AqDrvMex('AqD1_configTrigTV', instrumentID, channel, standard, field, line);