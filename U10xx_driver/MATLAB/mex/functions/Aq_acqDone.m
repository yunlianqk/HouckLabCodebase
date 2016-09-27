% Checks if the acquisition has terminated.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_acqDone.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status done]= Aq_acqDone(instrumentID)
warning ('Deprecated function. Please use AqD1_acqDone function')
[status done] = AqDrvMex('AqD1_acqDone', instrumentID);
