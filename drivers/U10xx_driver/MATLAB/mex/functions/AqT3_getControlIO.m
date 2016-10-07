% Gets the Control-IO connectors configuration the Time Counter
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: AqT3_getControlIO.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status signal qualifier1 qualifier2]= AqT3_getControlIO(instrumentID, connector)
[status signal qualifier1 qualifier2]= AqDrvMex('AqT3_getControlIO', instrumentID, connector);
