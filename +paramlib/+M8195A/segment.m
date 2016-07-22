classdef segment < handle
    % Part of the M8195A library.  waveset will contain a segment library
    % which is an array of these segment objects.
    % Segment object contains the waveform as well as other segment
    % specific settings. 
    %%%%%%%%% 
    % To do: list weird quirks of AWG and other limitations on segments
    % imposed by hardware.
    
    properties
        waveform; % vector of values to be drawn by AWG. Range +/- 1.
        id = 1; % reference used by playlist
        channel = 1; % hardware won't allow using same segment across channels?
        quadrature = 'I'; % specify I or Q
    end
    
    methods
%         function obj=segment() % constructor
%             % empty for now
%         end
        
        function draw(obj)
            % visualize
            figure(612)
            plot(obj.waveform)
        end
    end
end

        
        