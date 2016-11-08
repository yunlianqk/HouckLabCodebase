% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2007, 2008-2009 Agilent Technologies, Inc.
% $Id: AqG4_error_query.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status errorCode ] = AqG4_error_query(vi, errorMessage)
[status errorCode ] = AqDrvMex('AqG4_error_query', vi, errorMessage);
