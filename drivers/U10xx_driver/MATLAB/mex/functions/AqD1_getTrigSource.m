% Returns the current trigger source control parameters for a specified channel.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getTrigSource.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status trigCoupling trigSlope trigLevel1 trigLevel2] = AqD1_getTrigSource(instrumentID, channel)
[status trigCoupling trigSlope trigLevel1 trigLevel2] = AqDrvMex('AqD1_getTrigSource', instrumentID, channel);
