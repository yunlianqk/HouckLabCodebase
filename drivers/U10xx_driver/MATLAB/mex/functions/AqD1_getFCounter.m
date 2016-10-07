% Returns the current settings of the frequency counter
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getFCounter.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status signalChannel typeMes targetValue apertureTime reserved flags]= AqD1_getFCounter(instrumentID)
[status signalChannel typeMes targetValue apertureTime reserved flags]= AqDrvMex('AqD1_getFCounter', instrumentID);
