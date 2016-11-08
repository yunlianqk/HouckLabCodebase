% Returns the multiple input configuration on a channel
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getMultiInput.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status input] = AqD1_getMultiInput(instrumentID, channel)
[status input] = AqDrvMex('AqD1_getMultiInput', instrumentID, channel);
