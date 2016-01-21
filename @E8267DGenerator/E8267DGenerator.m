classdef E8267DGenerator < handle
% Contains paramaters and methods for E8267D vector generator

    properties (SetAccess = private, GetAccess = public)
        address;    % GPIB address
        instrhandle;    % gpib object for the instrument
    end
    properties (Access = public)
        frequency;
        power;
    end
    
    methods
        function gen = E8267DGenerator(address)
        % Open instrument
            gen.address = address;
            % If already opened
            gen.instrhandle = instrfind('Name', ['GPIB0-', num2str(gen.address)], ...
                                        'Status', 'open');
            % If not opened
            if isempty(gen.instrhandle)
                gen.instrhandle = gpib('ni', 0, gen.address);
                fopen(gen.instrhandle);
            end
            gen.GetParams();
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file        
        Finalize(gen);  % Close instrument
        GetParams(gen); % Read parameters from instrument and update
        SetFreq(gen, varargin);
        SetPower(gen, varargin);
        PowerOn(gen);
        PowerOff(gen);
        ModOn(gen);
        ModOff(gen);
    end
end