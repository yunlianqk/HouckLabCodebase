% Returns the number of channels on the specified instrument.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getNbrChannels.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status nbrChannels] = Aq_getNbrChannels(instrumentID)
[status nbrChannels] = AqDrvMex('Aq_getNbrChannels', instrumentID);
