% Restores some internal registers of an instrument, needed ONLY after power-up
% of a digitizer with the battery back-up option.
% Please refer to the manual for a detailed description of the steps required
% to read battery backed-up waveforms.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_restoreInternalRegisters.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = Aq_restoreInternalRegisters(instrumentID, delayOffset, delayScale)
warning ('Deprecated function. Please use AqD1_restoreInternalRegisters function')
[status ] = AqDrvMex('AqD1_restoreInternalRegisters', instrumentID, delayOffset, delayScale);
