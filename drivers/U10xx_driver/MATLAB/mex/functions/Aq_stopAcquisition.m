% Stops the acquisition immediately
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_stopAcquisition.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = Aq_stopAcquisition(instrumentID)
warning ('Deprecated function. Please use AqD1_stopAcquisition function')
[status ] = AqDrvMex('AqD1_stopAcquisition', instrumentID);
