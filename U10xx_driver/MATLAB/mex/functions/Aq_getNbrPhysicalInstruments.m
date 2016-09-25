% Returns the number of supported physical Acqiris digitizers found on the computer.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getNbrPhysicalInstruments.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nbrInstrument]= Aq_getNbrPhysicalInstruments()
warning ('Deprecated function. Please use AqD1_getNbrPhysicalInstruments function')
[status nbrInstrument] = AqDrvMex('AqD1_getNbrPhysicalInstruments');
