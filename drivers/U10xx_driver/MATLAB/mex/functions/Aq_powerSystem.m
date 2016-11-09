% Prepares all instruments for an immediate system power down.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_powerSystem.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status] = Aq_powerSystem(state, flags)
[status] = AqDrvMex('Aq_powerSystem', state, flags);
