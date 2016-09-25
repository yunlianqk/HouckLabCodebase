% Returns the current horizontal control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getHorizontal.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status sampInterval delayTime] = AqD1_getHorizontal(instrumentID)
[status sampInterval delayTime] = AqDrvMex('AqD1_getHorizontal', instrumentID);
