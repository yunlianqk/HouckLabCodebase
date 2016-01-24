classdef AWG33250A < handle
% Contains paramaters and methods for 33250A AWG

    properties (SetAccess = private, GetAccess = public)
        address;    % GPIB address
        instrhandle;    % gpib object for the instrument
    end
    properties (Access = private)
        waveoptions = {'square', 'sin'};
    end
    properties (Access = public)
        waveform = 'square';    % Can be either square or sine
        period = 20e-6; % Period in seconds
        vpp = 2.0;  % Peak-peak voltage in volts
        voffset = 1.0;  % Offset voltage in volts
    end
    
    methods
        function triggen = AWG33250A(address)
        % Openinstrhandle
            triggen.address = address;
            % If already opened
            triggen.instrhandle = instrfind('Name', ['GPIB0-', num2str(triggen.address)], ...
                                        'Status', 'open');
            % If not opened
            if isempty(triggen.instrhandle)
                triggen.instrhandle = gpib('ni', 0, triggen.address);
                fopen(triggen.instrhandle);
            end
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file
        Finalize(triggen);  % Close instrhandle
        SetParams(triggen);	% Set parameters and generate waveform
        SetPeriod(triggen, varargin);   % Set period
    end
end