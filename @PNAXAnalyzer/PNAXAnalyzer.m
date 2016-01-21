classdef PNAXAnalyzer < handle
% Contains paramaters and methods for PNA-X Network Analyzer

    properties (SetAccess = private, GetAccess = public)
        address;    % GPIB address
        instrhandle;    % gpib object for the instrument
        transtrace1 = 'CH1_TR1';    % Default measurement names
        transtrace2 = 'CH1_TR2';
        spectrace1 = 'CH2_TR3';
        spectrace2 = 'CH2_TR4';
    end
    properties (Access = public)
        transparams = struct('start', 5e9, ...
                             'stop', 6e9, ...
                             'points', 1001, ...
                             'power', -50, ...
                             'averages', 1000, ...
                             'ifbandwidth', 5e3);   % Parameters for transmission measurement
                         
        specparams = struct('start', 4e9, ...
                            'stop', 5e9, ...
                            'points', 1001, ...
                            'power', -50, ...
                            'averages', 1000, ...
                            'ifbandwidth', 5e3, ...
                            'cwfreq', 7e9, ...
                            'cwpower', -50);    % Parameters for spectroscopy measurement
    end
    
    methods
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
        Finalize(pnax); % Close instrument
        SetDefault(pnax);   % Configure PNAX to default settings
        SetTransParams(pnax);   % Perform transmission measurement
        SetSpecParams(pnax);    % Perform spectroscopy measurement
        data = Read(pnax); % Return the currently active trace
        xaxis = GetAxis(pnax);  % Return the x-axis of the currently active channel
    end
end