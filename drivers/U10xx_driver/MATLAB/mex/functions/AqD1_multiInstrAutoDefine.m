% Automatically combines as many digitizers as possible to "MultiInstrument"s.
% Digitizers are only combined if they are physically connected via ASBus.
% This call must be followed by 'nbrInstruments' calls to 'AcqrsD1_init' or 
% 'AcqrsD1_InitWithOptions' to retrieve the 'instrumentID's of the (multi)digitizers.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_multiInstrAutoDefine.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nbrInstruments] = AqD1_multiInstrAutoDefine(optionsString)
[status nbrInstruments] = AqDrvMex('AqD1_multiInstrAutoDefine', optionsString);
