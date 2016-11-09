% Helper function to ease the instrument configuration.
% Returns maximum nominal number of samples which fits into the available memory.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_bestNominalSamples.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nomSamples]= Aq_bestNominalSamples(instrumentID)
warning ('Deprecated function. Please use AqD1_bestNominalSamples function')
[status nomSamples] = AqDrvMex('AqD1_bestNominalSamples', instrumentID);
