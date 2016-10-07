% Restores some internal registers of an instrument, needed ONLY after power-up
% of a digitizer with the battery back-up option.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_restoreInternalRegisters.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = AqD1_restoreInternalRegisters(instrumentID, delayOffset, delayScale)
[status ] = AqDrvMex('AqD1_restoreInternalRegisters', instrumentID, delayOffset, delayScale);
