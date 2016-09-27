% Returns the current trigger source control parameters for a specified channel.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getTrigSource.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status trigCoupling trigSlope trigLevel1 trigLevel2] = Aq_getTrigSource(instrumentID, channel)
warning ('Deprecated function. Please use AqD1_getTrigSource function')
[status trigCoupling trigSlope trigLevel1 trigLevel2] = AqDrvMex('AqD1_getTrigSource', instrumentID, channel);
