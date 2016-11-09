% Returns the API interface type appropriate to this 'instrumentID' and 'channel'.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getChanDevType.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status devType] = Aq_getChanDevType(instrumentID, channel)
[status devType] = AqDrvMex('Aq_getChanDevType', instrumentID, channel);
