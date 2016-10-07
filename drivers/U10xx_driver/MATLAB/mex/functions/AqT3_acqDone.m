% Checks if the acquisition has terminated.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: AqT3_acqDone.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status done]= AqT3_acqDone(instrumentID)
[status done] = AqDrvMex('AqT3_acqDone', instrumentID);
