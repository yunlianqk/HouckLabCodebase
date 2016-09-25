%    Reads the frequency counter
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_readFCounter.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status result] = Aq_readFCounter(instrumentID)
warning ('Deprecated function. Please use AqD1_readFCounter function')
[status result] = AqDrvMex('AqD1_readFCounter', instrumentID);
