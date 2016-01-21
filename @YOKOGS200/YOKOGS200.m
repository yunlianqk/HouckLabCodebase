classdef YOKOGS200 < handle
% Contains paramaters and methods for YOKOGAWA GS200 voltage source

    properties (SetAccess = private, GetAccess = public)
        address;    % GPIB address
        instrhandle;    % gpib object for the instrument
    end
    properties (Access = public)
        voltage;
        rampstep = 0.002;   % increment step when setting voltage
        rampinterval = 0.01;    % dwell time for each voltage step
    end
    
    methods
        function yoko = YOKOGS200(address)
        % Openinstrhandle
            yoko.address = address;
            % If already opened
            yoko.instrhandle = instrfind('Name', ['GPIB0-', num2str(yoko.address)], ...
                                        'Status', 'open');
            % If not opened
            if isempty(yoko.instrhandle)
                yoko.instrhandle = gpib('ni', 0, yoko.address);
                fopen(yoko.instrhandle);
            end
            yoko.GetVoltage();
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file        
        Finalize(yoko); % Close instrhandle
        GetVoltage(yoko);   % Get voltage
        SetVoltage(yoko, varargin); % Set voltage
        PowerOn(yoko);  % Turn on output
        PowerOff(yoko);    % Turn off output
    end
end