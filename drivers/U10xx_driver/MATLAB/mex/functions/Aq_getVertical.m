% Returns the current vertical control parameters for a specified channel.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getVertical.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status fullScale offset coupling bandwidth] = Aq_getVertical(instrumentID, channel)
warning ('Deprecated function. Please use AqD1_getVertical function')
[status fullScale offset coupling bandwidth] = AqDrvMex('AqD1_getVertical', instrumentID, channel);
