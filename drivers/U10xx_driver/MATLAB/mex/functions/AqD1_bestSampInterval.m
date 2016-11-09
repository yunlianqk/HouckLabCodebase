% Helper function to ease the instrument configuration.
% Returns the best possible sampling rate for an acquisition which covers the 'timeWindow'
% with no more than 'maxSamples', taking into account the current state of the instrument,
% in particular the requested channel combination and the number of segments.
% In addition, this routine returns the 'real' nominal number of samples which can
% be accommodated (it is computed as timeWindow/sampInterval !).
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_bestSampInterval.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status sampInterval nomSamples]= AqD1_bestSampInterval(instrumentID, maxSamples, timeWindow)
[status sampInterval nomSamples] = AqDrvMex('AqD1_bestSampInterval', instrumentID, maxSamples, timeWindow);
