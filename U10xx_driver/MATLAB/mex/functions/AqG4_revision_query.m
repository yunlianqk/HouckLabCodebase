% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2007, 2008-2009 Agilent Technologies, Inc.
% $Id: AqG4_revision_query.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status driverRev instrRev ] = AqG4_revision_query(vi)
[status driverRev instrRev ] = AqDrvMex('AqG4_revision_query', vi);
