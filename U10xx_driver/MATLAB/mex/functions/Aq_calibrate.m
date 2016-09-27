% Performs an auto-calibration of the instrument
% Equivalent to Acqrs_calibrateEx with 'calType' = 0
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_calibrate.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_calibrate(instrumentID)
[status ] = AqDrvMex('Aq_calibrate', instrumentID);
