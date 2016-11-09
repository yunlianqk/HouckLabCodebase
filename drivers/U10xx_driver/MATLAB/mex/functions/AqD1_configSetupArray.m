% Configures an array of setup data (typically for on-board processing)
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2005, 2006-2009 Agilent Technologies, Inc.
% $Id: AqD1_configSetupArray.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= AqD1_configSetupArray(instrumentID, channel, setupType, nbrSetupObj, setupData)
[status ] = AqDrvMex('AqD1_configSetupArray', instrumentID, channel, setupType, nbrSetupObj, setupData);
