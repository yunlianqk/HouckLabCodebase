% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2007, 2008-2009 Agilent Technologies, Inc.
% $Id: AqG4_QueryArbSeqCapabilities.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status maxNumSegs minSeqLength maxSegLength maxLoopCount ] = AqG4_QueryArbSeqCapabilities(vi)
[status maxNumSegs minSeqLength maxSegLength maxLoopCount ] = AqDrvMex('AqG4_QueryArbSeqCapabilities', vi);
