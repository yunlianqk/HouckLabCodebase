% Stops the on-board processing immediately.(only in instruments with on-board data processing)
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_stopProcessing.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = Aq_stopProcessing(instrumentID)
warning ('Deprecated function. Please use AqD1_stopProcessing function')
[status ] = AqDrvMex('AqD1_stopProcessing', instrumentID);
