% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2007, 2008-2009 Agilent Technologies, Inc.
% $Id: AqG4_ConfigureInternalTriggerRate.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = AqG4_ConfigureInternalTriggerRate(vi, rate)
[status ] = AqDrvMex('AqG4_ConfigureInternalTriggerRate', vi, rate);
