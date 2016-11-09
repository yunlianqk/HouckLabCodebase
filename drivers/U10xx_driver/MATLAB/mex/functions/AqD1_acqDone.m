% Checks if the acquisition has terminated.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_acqDone.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status done]= AqD1_acqDone(instrumentID)
[status done] = AqDrvMex('AqD1_acqDone', instrumentID);
