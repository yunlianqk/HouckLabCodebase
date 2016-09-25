% Close specified instrument. Once closed, this instrument is not available anymore and
% need to be reenabled using 'InitWithOptions' or 'init'.
% Note: For freeing properly all resources, 'closeAll' must still be called when
% the application close, even if 'close' was called for each instrument.
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_close.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ]= Aq_close(instrumentID)
[status] = AqDrvMex('Aq_close', instrumentID);
