% Returns parameters of combined operation of multiple channels
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getChannelCombination.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nbrConvertersPerChannel usedChannels]= Aq_getChannelCombination(instrumentID)
warning ('Deprecated function. Please use AqD1_getChannelCombination function')
[status nbrConvertersPerChannel usedChannels] = AqDrvMex('AqD1_getChannelCombination', instrumentID);
