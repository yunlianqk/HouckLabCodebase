% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2007, 2008-2009 Agilent Technologies, Inc.
% $Id: AqG4_ConfigureTriggerSource.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = AqG4_ConfigureTriggerSource(vi, channelName, source)
[status ] = AqDrvMex('AqG4_ConfigureTriggerSource', vi, channelName, source);
