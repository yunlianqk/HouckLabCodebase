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
        applyFilter = true; % currently only have a filter for qubit pulses
    end
    
    methods
        function obj=segment(waveform) % constructor
            % check waveform is just a vector
            if ~isvector(waveform)
                error('Waveform must be a vector');
            end
            % check waveform doesn't go above or below 1
            if max(abs(waveform))>1
                error('Waveform range beyond +/- 1');
            end
            obj.waveform=waveform;
        end
        
        function draw(obj)
            % visualize
            figure()
            plot(obj.waveform)
            str={['id: ' num2str(obj.id)],...
                 ['channel: ' num2str(obj.channel)],...
                 ['quadrature: ' obj.quadrature],...
                 ['applyFilter: ' num2str(obj.applyFilter)]};
            dim = [.7 .8 .1 .1];
            t = annotation('textbox',dim,'String',str);
            
        end
    end
end

        
        