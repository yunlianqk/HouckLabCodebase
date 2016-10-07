% Helper function to ease the instrument configuration.
% Returns maximum nominal number of samples which fits into the available memory.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_bestNominalSamples.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nomSamples]= AqD1_bestNominalSamples(instrumentID)
[status nomSamples] = AqDrvMex('AqD1_bestNominalSamples', instrumentID);
