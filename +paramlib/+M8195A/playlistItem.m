classdef playlistItem < handle
    % Part of the M8195A library.  waveset will contain a playlist which is
    % an array of playlist items.  each item contains a reference to a
    % segment object as well as loop count and trigger settings
    
    properties
        segment; % handle to a segment object within the segment library
        loops = 1; % number of times to repeat before moving to next playlist item
        markerEnable = true; % should probably always be true?
        advance = 'Auto'; % Should be 'Conditional' if next item on playlist should wait until another trigger
    end
    
    methods
        
        
        
        
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
            figure(612);
            plot(final);
        end
    end
end

        
        