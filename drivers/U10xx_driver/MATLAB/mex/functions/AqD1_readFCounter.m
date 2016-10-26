%    Reads the frequency counter
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_readFCounter.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status result] = AqD1_readFCounter(instrumentID)
[status result] = AqDrvMex('AqD1_readFCounter', instrumentID);
