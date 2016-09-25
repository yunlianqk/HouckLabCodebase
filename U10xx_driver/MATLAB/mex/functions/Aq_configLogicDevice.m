% Load/Clear/SetFilePath of the on-board logic devices. ONLY useful for a module 
% with on-board programmable logic devices 
% (SCxxx, ACxxx, APxxx, RCxxx, and 12-bit Digitizers).
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_configLogicDevice.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_configLogicDevice(instrumentID, deviceName, filePathName, flags)
[status ] = AqDrvMex('Aq_configLogicDevice', instrumentID, deviceName, filePathName, flags);
