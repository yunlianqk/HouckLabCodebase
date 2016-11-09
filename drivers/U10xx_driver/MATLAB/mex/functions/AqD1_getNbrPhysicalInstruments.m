% Returns the number of supported physical Acqiris digitizers found on the computer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getNbrPhysicalInstruments.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nbrInstrument]= AqD1_getNbrPhysicalInstruments()
[status nbrInstrument] = AqDrvMex('AqD1_getNbrPhysicalInstruments');
