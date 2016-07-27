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
        channelMap = [1 0; 0 0; 0 0; 0 0];% [Ch1I Ch1Q; Ch2I Ch2Q; Ch3I Ch3Q; Ch4I Ch4Q]
        id; % reference used by playlist. different segments with the same id (different channels) will be played simultaneously.
        applyFilter = true; % used to determine which waveforms get calibration filter
        keepOpen = 1; % keeps connection to awg open
        run = 0; % setting this to 1 means it will run as soon as it's downloaded by awg
    end
    
    methods
        function obj=segment(waveform, varargin) % constructor
            % check and store waveform
            obj.checkWaveform(waveform)
            obj.waveform=waveform;
            % optional arguments
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.channelMap = varargin{1};
                case 2
                    obj.channelMap = varargin{1};
                    obj.applyFilter = varargin{2};
                case 3
                    obj.channelMap = varargin{1};
                    obj.applyFilter = varargin{2};
                    obj.id = varargin{3};
                case 4
                    obj.channelMap = varargin{1};
                    obj.applyFilter = varargin{2};
                    obj.id = varargin{3};
                    obj.keepOpen = varargin{4};
                case 5
                    obj.channelMap = varargin{1};
                    obj.applyFilter = varargin{2};
                    obj.id = varargin{3};
                    obj.keepOpen = varargin{4};                  
                    obj.run = varargin{5};
            end
        end
        
        function checkWaveform(obj,waveform)
            % check waveform is just a vector
            if ~isvector(waveform)
                error('Waveform must be a vector');
            end
            % check waveform doesn't go above or below 1
            if max(abs(waveform))>1
                error('Waveform range beyond +/- 1');
            end
        end
        
        function draw(obj)
            % visualize
            figure()
            plot(obj.waveform)
            str={['id: ' num2str(obj.id)],...
                 ['channelMap: ' mat2str(obj.channelMap)],...
                 ['applyFilter: ' num2str(obj.applyFilter)]};
            dim = [.7 .8 .1 .1];
            t = annotation('textbox',dim,'String',str);
            
        end
    end
end

        
        