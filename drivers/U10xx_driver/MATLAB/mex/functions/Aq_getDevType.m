% Returns the device type of the specified 'instrumentID'
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getDevType.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status devType]= Aq_getDevType(instrumentID)
[status devType] = AqDrvMex('Aq_getDevType', instrumentID);