% Resume control of an instrument.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_resumeControl.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status] = Aq_resumeControl(instrumentID)
[status] = AqDrvMex('Aq_resumeControl', instrumentID);
