% Sets the front-panel LED to the desired color
% 'color' = 0        OFF (returns to normal 'acquisition status' indicator)
%           1        Green
%           2        Red
%           3        Yellow
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_setLEDColor.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = Aq_setLEDColor(instrumentID, color)
[status ] = AqDrvMex('Aq_setLEDColor', instrumentID, color);
