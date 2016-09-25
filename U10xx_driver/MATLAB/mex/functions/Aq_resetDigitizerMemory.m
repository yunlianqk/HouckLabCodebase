% Resets the digitizer memory to a known default state, ONLY useful
% for a digitizer with the battery back-up option. 
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_resetDigitizerMemory.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = Aq_resetDigitizerMemory(instrumentID)
warning ('Deprecated function. Please use AqD1_resetDigitizerMemory function')
[status ] = AqDrvMex('AqD1_resetDigitizerMemory', instrumentID);
