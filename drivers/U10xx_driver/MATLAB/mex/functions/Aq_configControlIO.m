% Configures Control-IO connectors
% Typically, only a few (or no) IO connectors are present on a single digitizer
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configControlIO.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configControlIO(instrumentID, connector, signal, qualifier1, qualifier2)
warning ('Deprecated function. Please use AqD1_configControlIO function')
[status ] = AqDrvMex('AqD1_configControlIO', instrumentID, connector, signal, qualifier1, qualifier2);
