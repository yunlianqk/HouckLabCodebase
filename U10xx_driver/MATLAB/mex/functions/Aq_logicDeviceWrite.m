% ONLY useful for a module with on-board programmable logic devices 
% (SCxxx, ACxxx, APxxx, RCxxx, and 12-bit Digitizers).
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_logicDeviceWrite.m 36590 2009-09-18 07:59:42Z bdonnier $

function [status] = Aq_logicDeviceWrite(instrumentID, deviceName, registerID, nbrValues, dataArray, modifier)

% We test here the mismatch between the type and the number of values to avoid
% writing on registers that the user doesn't want to write.
if isa(dataArray, 'int8') & mod(nbrValues, 4)
    error('Non multiple of 4 nbrValues forbiden with int8 type')
elseif isa(dataArray, 'uint8') & mod(nbrValues, 4)
    error('Non multiple of 4 nbrValues forbiden with uint8 type')
elseif isa(dataArray, 'int16') & mod(nbrValues, 2)
    error('Non multiple of 2 nbrValues forbiden with int16 type')
elseif isa(dataArray, 'uint16') & mod(nbrValues, 2)
    error('Non multiple of 2 nbrValues forbiden with uint16 type')
else
    [status] = AqDrvMex('Aq_logicDeviceWrite', instrumentID, deviceName, registerID, nbrValues, dataArray, modifier);
end
