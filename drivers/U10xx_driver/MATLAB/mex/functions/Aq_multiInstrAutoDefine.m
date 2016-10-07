% Automatically combines as many digitizers as possible to "MultiInstrument"s.
% Digitizers are only combined if they are physically connected via ASBus.
% This call must be followed by 'nbrInstruments' calls to 'AcqrsD1_init' or 
% 'AcqrsD1_InitWithOptions' to retrieve the 'instrumentID's of the (multi)digitizers.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_multiInstrAutoDefine.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nbrInstruments] = Aq_multiInstrAutoDefine(optionsString)
warning ('Deprecated function. Please use AqD1_multiInstrAutoDefine function')
[status nbrInstruments] = AqDrvMex('AqD1_multiInstrAutoDefine', optionsString);
