% Initializes an instrument with options
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_InitWithOptions.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status instrumentID]= Aq_InitWithOptions(resourceName, IDQuery, resetDevice, optionsString)
[status instrumentID] = AqDrvMex('Aq_InitWithOptions', resourceName, IDQuery, resetDevice, optionsString);
