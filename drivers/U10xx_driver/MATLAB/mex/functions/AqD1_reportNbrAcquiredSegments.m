% Returns the number of segments already acquired.
% Can be called during the acquisition period, in order to follow the progress of a
% Sequence acquisition. 
% Can be called after an acquisition, in order to obtain the number of segments actually
% acquired (until 'AcqrsD1_stopAcquisition' was called).
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_reportNbrAcquiredSegments.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nbrSegments] = AqD1_reportNbrAcquiredSegments(instrumentID)
[status nbrSegments] = AqDrvMex('AqD1_reportNbrAcquiredSegments', instrumentID);
