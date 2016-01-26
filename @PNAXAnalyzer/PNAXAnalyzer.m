classdef PNAXAnalyzer < handle
% Contains paramaters and methods for PNA-X Network Analyzer
% To set up a transmission or specstroscopy scan, fill the field in
% transparams or specparams. Running SetTransParams() or SetSpecParams()
% will then set up the measurement. 
% The 'trace' field specifies which trace you want to store the scan.
% Running SetActiveTrace(trace) will activate the specified trace.
% Running Read() will read the currently active trace.
% Running GetAxis() will read the x-axis.
% The 'meastype' field takes values like 'S21', 'S11', etc.
% The 'format' field takes values like 'MLOG', 'MLIN', 'PHAS', 'UPH', etc. 
% An error messege will appear if a field is set to a wrong value.

    properties (SetAccess = private, GetAccess = public)
        address;    % GPIB address
        instrhandle;    % gpib object for the instrument
    end
    properties (Access = public)
        transparams = struct('start', 5e9, ...
                             'stop', 6e9, ...
                             'points', 1001, ...
                             'power', -50, ...
                             'averages', 1000, ...
                             'ifbandwidth', 5e3, ...
                             'trace', 1, ...
                             'meastype', 'S21', ...
                             'format', 'MLOG');	% Parameters for transmission measurement
                         
        specparams = struct('start', 4e9, ...
                            'stop', 5e9, ...
                            'points', 1001, ...
                            'power', -50, ...
                            'averages', 1000, ...
                            'ifbandwidth', 5e3, ...
                            'cwfreq', 7e9, ...
                            'cwpower', -50, ...
                            'trace', 2, ...
                            'meastype', 'S21', ...
                            'format', 'MLOG');  % Parameters for spectroscopy measurement
    end
    properties (Access = private)
        transchannel  = 1;
        specchannel = 2;
    end
    methods (Access = public)
        function pnax = PNAXAnalyzer(address)
        % Open instrument
            pnax.address = address;
            pnax.instrhandle = instrfind('Name', ['GPIB0-', num2str(pnax.address)], ...
                                        'Status', 'open');
            if isempty(pnax.instrhandle)
                pnax.instrhandle = gpib('ni', 0, pnax.address);
                fopen(pnax.instrhandle);
            end
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file
        Finalize(pnax);	% Close instrument
        SetTransParams(pnax);	% Perform transmission measurement
        SetSpecParams(pnax);	% Perform spectroscopy measurement
        data = Read(pnax);	% Read the currently active trace
        xaxis = GetAxis(pnax);	% Return the x-axis of the currently active channel
        CreateMeas(pnax, channel, trace, meas, format);	% Create a measurement
        SetActiveTrace(pnax, trace);	% Set active trace
    end
    methods (Access = protected)
        trlist = GetTraces(pnax);	% Get existing traces
        measlist = GetMeasurements(pnax, channel);	% Get existing measurements in a channel
        CheckParams(pnax, params);	% Check the correctness of some parameters
        measname = MeasName(pnax, channel, trace);	% Generate name for a measurement
    end
end