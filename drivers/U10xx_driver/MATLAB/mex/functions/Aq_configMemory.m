

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configMemory.m 33903 2009-01-26 16:45:39Z bdonnier $
% Configures the memory control parameters of the digitizer.
%
% Please refer to the Programmer's Reference Manual for more information.
%
function [status ]= Aq_configMemory(instrumentID, nbrSamples, nbrSegments)
warning ('Deprecated function. Please use AqD1_configMemory function')
[status ] = AqDrvMex('AqD1_configMemory', instrumentID, nbrSamples, nbrSegments);
