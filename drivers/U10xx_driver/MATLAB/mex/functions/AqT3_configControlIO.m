% Configures Control-IO connectors of the Time Counter
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: AqT3_configControlIO.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqT3_configControlIO(instrumentID, connector, signal, qualifier1, qualifier2)
[status ] = AqDrvMex('AqT3_configControlIO', instrumentID, connector, signal, qualifier1, qualifier2);