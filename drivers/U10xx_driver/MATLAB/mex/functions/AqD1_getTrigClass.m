% Returns the current trigger class control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getTrigClass.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status trigClass sourcePattern validatePattern holdType holdValue1 holdValue2] = AqD1_getTrigClass(instrumentID)
[status trigClass sourcePattern validatePattern holdType holdValue1 holdValue2] = AqDrvMex('AqD1_getTrigClass', instrumentID);
