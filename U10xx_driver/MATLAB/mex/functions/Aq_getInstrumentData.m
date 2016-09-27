% Returns some basic data about a specified instrument
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getInstrumentData.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status name serialNbr busNbr slotNbr]= Aq_getInstrumentData(instrumentID)
[status name serialNbr busNbr slotNbr] = AqDrvMex('Aq_getInstrumentData', instrumentID);
