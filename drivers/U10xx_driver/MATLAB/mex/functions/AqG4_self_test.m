% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2007, 2008-2009 Agilent Technologies, Inc.
% $Id: AqG4_self_test.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status testResult testMessage ] = AqG4_self_test(vi)
[status testResult testMessage ] = AqDrvMex('AqG4_self_test', vi);
