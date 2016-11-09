% Returns general information about a specified instrument
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getInstrumentInfo.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status infoValue] = Aq_getInstrumentInfo(instrumentID, parameterString, dataTypeString)
[status infoValue] = AqDrvMex('Aq_getInstrumentInfo', instrumentID, parameterString, dataTypeString);
