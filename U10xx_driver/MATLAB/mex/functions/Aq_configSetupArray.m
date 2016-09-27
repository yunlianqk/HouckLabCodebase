% Configures an array of setup data (typically for on-board processing)
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configSetupArray.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configSetupArray(instrumentID, channel, setupType, nbrSetupObj, setupData)
warning ('Deprecated function. Please use AqD1_configSetupArray function')
[status ] = AqDrvMex('AqD1_configSetupArray', instrumentID, channel, setupType, nbrSetupObj, setupData);
