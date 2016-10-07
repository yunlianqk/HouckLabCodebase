% Generate a COMMON hit by software. Currently only supported on TC890.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: AqT3_forceTrig.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status] = AqT3_forceTrig(instrumentID, forceTrigType, modifier, flags)
[status] = AqDrvMex('AqT3_forceTrig', instrumentID, forceTrigType, modifier, flags);
