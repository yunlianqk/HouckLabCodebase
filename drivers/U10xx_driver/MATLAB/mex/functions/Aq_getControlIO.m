% Returns the state of Control-IO connectors
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getControlIO.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status signal qualifier1 qualifier2]= AqD1_getControlIO(instrumentID, connector)
warning ('Deprecated function. Please use AqD1_getControlIO function')
[status signal qualifier1 qualifier2]= AqDrvMex('AqD1_getControlIO', instrumentID, connector);
