% Checks if the on-board processing has terminated.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_procDone.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status done] = Aq_procDone(instrumentID)
warning ('Deprecated function. Please use AqD1_procDone function')
[status done] = AqDrvMex('AqD1_procDone', instrumentID);
