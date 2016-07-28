classdef playlistItem < handle
    % Part of the M8195A library.  waveset will contain a playlist which is
    % an array of playlist items.  each item contains a reference to a
    % segment object as well as loop count and trigger settings
    
    properties
        segment; % handle to a segment object within the segment library
        advance = 'Stepped'; % 'Stepped' will cause segment to play and then sample to be repeated until next trigger. Final item of playlist must be set to 'Auto' though.
        loops = 1; % number of times to repeat before moving to next playlist item
        markerEnable = true; % should probably always be true?
        waveformIndex; % when added to playlist this keeps track of which waveform the entry is part of - based on the advance properties of playlist items before it.
    end
    
    methods
        function obj=playlistItem(segment, varargin) % constructor
            obj.segment = segment;
            nVarargs = length(varargin);
            switch nVarargs
                case 1
                    obj.advance = varargin{1};
                case 2
                    obj.advance = varargin{1};
                    obj.loops = varargin{2};
                case 3
                    obj.advance = varargin{1};
                    obj.loops = varargin{2};
                    obj.markerEnable = varargin{3};
            end
        end
        
        function draw(obj)
            % visualize
            wf = obj.segment.waveform;
            if size(wf,1) > 1 % make sure its oriented so it can be concatenated
                wf = wf';
            end
            if obj.loops > 1 % repeat waveform
                final = repmat(wf,1,obj.loops);
            else
                final = wf;
            end            
            figure();
            plot(final);
            str={['Segment ID: ' num2str(obj.segment.id)],...
                 ['Loops: ' num2str(obj.loops)],...
                 ['markerEnable: ' num2str(obj.markerEnable)],...
                 ['advance: ' num2str(obj.advance)]};
            dim = [.7 .8 .1 .1];
            t = annotation('textbox',dim,'String',str);
        end
    end
end

        
        