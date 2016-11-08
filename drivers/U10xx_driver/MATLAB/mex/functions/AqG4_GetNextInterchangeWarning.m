% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2007, 2008-2009 Agilent Technologies, Inc.
% $Id: AqG4_GetNextInterchangeWarning.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status interchangeWarning ] = AqG4_GetNextInterchangeWarning(vi, interchangeWarningSize)
[status interchangeWarning ] = AqDrvMex('AqG4_GetNextInterchangeWarning', vi, interchangeWarningSize);
