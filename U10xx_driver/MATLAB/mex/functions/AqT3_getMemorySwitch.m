% Gets the memory switch conditions the Time Counter.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: AqT3_getMemorySwitch.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status switchEnableP countEventP sizeMemoryP reservedP]= AqT3_getMemorySwitch(instrumentID)
[status switchEnableP countEventP sizeMemoryP reservedP]= AqDrvMex('AqT3_getMemorySwitch', instrumentID);
