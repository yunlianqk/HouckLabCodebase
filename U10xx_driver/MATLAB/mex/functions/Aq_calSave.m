% Save in 'filePathName' binary file all calibration values and info.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_calSave.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status] = Aq_calSave(instrumentID, filePathName, flags)
[status] = AqDrvMex('Aq_calSave', instrumentID, filePathName, flags);
