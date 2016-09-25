% Returns the current horizontal control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getHorizontal.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status sampInterval delayTime] = Aq_getHorizontal(instrumentID)
warning ('Deprecated function. Please use AqD1_getMemory function')
[status sampInterval delayTime] = AqDrvMex('AqD1_getHorizontal', instrumentID);
