% Sets one or several options which will be used by the function 'Acqrs_InitWithOptions',
% provided that the 'optionString' supplied to 'Acqrs_InitWithOptions' contains the
% string 'simulate=TRUE' (or similar).
%
% Please refer to the Programmer's Reference Manual for more information.
%

% (c) Copyright 2006, 2007-2009 Agilent Technologies, Inc.
% $Id: Aq_setSimulationOptions.m 33903 2009-01-26 16:45:39Z bdonnier $

function [status ] = Aq_setSimulationOptions(simOptionsString)
[status ] = AqDrvMex('Aq_setSimulationOptions', simOptionsString);
