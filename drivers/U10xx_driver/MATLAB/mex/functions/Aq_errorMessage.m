% Translates an error code into a human readable form. For file errors, the returned message 
% will also contain the file name and the original 'ansi' error string.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_errorMessage.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status errorMessage]= Aq_errorMessage(instrumentID, errorCode)
[status errorMessage] = AqDrvMex('Aq_errorMessage', instrumentID, errorCode);