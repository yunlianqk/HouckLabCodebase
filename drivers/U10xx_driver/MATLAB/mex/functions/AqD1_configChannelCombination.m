% Configures combined operation of multiple channels
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_configChannelCombination.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqD1_configChannelCombination(instrumentID, nbrConvertersPerChannel, usedChannels)
[status ] = AqDrvMex('AqD1_configChannelCombination', instrumentID, nbrConvertersPerChannel, usedChannels);
