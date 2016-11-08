% Returns the current trigger class control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getTrigClass.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status trigClass sourcePattern validatePattern holdType holdValue1 holdValue2] = Aq_getTrigClass(instrumentID)
warning ('Deprecated function. Please use AqD1_getTrigClass function')
[status trigClass sourcePattern validatePattern holdType holdValue1 holdValue2] = AqDrvMex('AqD1_getTrigClass', instrumentID);
