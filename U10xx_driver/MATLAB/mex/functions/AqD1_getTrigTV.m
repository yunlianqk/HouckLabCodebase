% Returns the current TV trigger control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getTrigTV.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status standard field line] = AqD1_getTrigTV(instrumentID, channel)
[status standard field line] = AqDrvMex('AqD1_getTrigTV', instrumentID, channel);
