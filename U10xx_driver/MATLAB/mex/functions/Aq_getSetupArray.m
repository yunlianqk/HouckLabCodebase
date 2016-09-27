% Returns setup data array (typically used for on-board processing).
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_getSetupArray.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status setupData nbrSetupObjReturned] = Aq_getSetupArray(instrumentID, channel, setupType, nbrSetupObj)
warning ('Deprecated function. Please use AqD1_getSetupArray function')
[status setupData nbrSetupObjReturned] = AqDrvMex('AqD1_getSetupArray', instrumentID, channel, setupType, nbrSetupObj);
