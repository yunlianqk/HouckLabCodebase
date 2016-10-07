% Returns version numbers associated with a specified instrument / current device driver
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getVersion.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status version] = Aq_getVersion(instrumentID, versionItem)
[status version] = AqDrvMex('Aq_getVersion', instrumentID, versionItem);
