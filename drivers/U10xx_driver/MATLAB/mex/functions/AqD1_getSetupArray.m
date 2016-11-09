% Returns setup data array (typically used for on-board processing).
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_getSetupArray.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status setupData nbrSetupObjReturned] = AqD1_getSetupArray(instrumentID, channel, setupType, nbrSetupObj)
[status setupData nbrSetupObjReturned] = AqDrvMex('AqD1_getSetupArray', instrumentID, channel, setupType, nbrSetupObj);
