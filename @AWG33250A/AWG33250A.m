classdef AWG33250A < handle
% Contains paramaters and methods for 33250A AWG

    properties (SetAccess = private, GetAccess = public)
        address;    % GPIB address
        instrhandle;    % gpib object for the instrument
    end
    properties (Access = public)
        period = 20e-6; 
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
        SetPeriod(triggen, period);	% Set period
    end
end