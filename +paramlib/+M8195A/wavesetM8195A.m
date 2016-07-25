classdef wavesetM8195A < handle
    % Basically an object/interface for generating the files to be run by
    % the ultrafast AWG (M8195A). Experiment code will generate the waveset 
    % object which can be saved for later use.  M8195A object will have 
    % methods for loading a waveset and then running it.
    % M8195a is the superfast 65GS/s direct synthesis AWG.
    
    properties
        % M8195A Settings
        samplingRate = 32.5e9; % Will this be universal for the entire waveset?
        triggerRate = 1/111e6;
        voltageRange = .5; % Output range of AWG in Volts
        % add other settings for AWG that might need to get changed...
        
        % Object Arrays
        segmentLibrary; % array of segment objects
        playlist; % array of playlist items to organize segments
    end
    
    methods
        function obj=wavesetM8195A() % constructor
            % generating an empty waveset object.
        end
        
        function s = newSegment(obj,waveform,varargin)
            % create a new segment from waveform and add it to the
            % segmentLibrary. automatically sets id and uses defaults for
            % other parameters. Segments are handle objects so the returned
            % segment can be altered (channel, quadrature etc.) and those 
            % changes will show up in the segmentLibrary
            s=paramlib.M8195A.segment(waveform,varargin);
            obj.addSegment(s);
        end
        
        function addSegment(obj,segment)
            % adds a segment object into the segmentLibrary. Changes id of
            % segment object to match it's location within the library
            if isempty(obj.segmentLibrary)
                newId = 1;
                segment.id = newId; % change segment's id
                obj.segmentLibrary = segment; 
            else
                newId = size(obj.segmentLibrary,2) + 1;
                segment.id = newId; % change segment's id
                obj.segmentLibrary(newId) = segment; % add segment to end of library    
            end
        end
        
        function p = newPlaylistItem(obj,segment,varargin)
            % appends a new playlistItem to the end of the playlist.
            % playlistItems are handle objects so the returned
            % object can be altered and those changes propagate correctly
            p=paramlib.M8195A.playlistItem(segment,varargin);
            obj.addPlaylistItem(p);
        end
        
        function addPlaylistItem(obj,playlistItem)
            % adds a playlistItem object to the end of the playlist. 
            if isempty(obj.playlist)
                playlistItem.waveformIndex = 1;
                obj.playlist = playlistItem; 
            else
                playlistPosition = size(obj.playlist,2) + 1;
                lastItem = obj.playlist(playlistPosition-1);
                if strcmp(lastItem.advance,'Auto')
                    playlistItem.waveformIndex = lastItem.waveformIndex;
                else
                    playlistItem.waveformIndex = lastItem.waveformIndex+1;
                end
                obj.playlist(playlistPosition) = playlistItem;
            end
        end
        
        
        function drawSegmentLibrary(obj)
            % visualize the segment library 
            libSize = size(obj.segmentLibrary,2);
            tstep = 1/obj.samplingRate;
            figure();
            ax=axes();
            title('Segment Library')
            hold(ax,'on');
            for ind = 1:libSize
                s = obj.segmentLibrary(ind);
                y = s.waveform+2.5*(ind-1);
                % y = s.waveform;
                x = tstep.*(0:(length(y)-1));
                plot(ax,x,y)
            end
        end
        
        function drawPlaylist(obj)
            % visualize the playlist
            % this needs to be updated to concatenate playlist items until
            % it hits an item that has advance set to 'Conditional' 
            playlistSize = size(obj.playlist,2);
            tstep = 1/obj.samplingRate;
            figure();
            ax=axes();
            title('Playlist')
            hold(ax,'on');
            
            currentWaveform = [];
            for ind = 1:playlistSize
                p = obj.playlist(ind);
                s = p.segment;
                w = s.waveform;
                y = repmat(w,1,p.loops);
                currentWaveform = [currentWaveform y];
                % whenever conditional trigger setting found, we are done
                % with a waveform.
                if strcmp(p.advance,'Conditional') % plot and reset
                    plot(ax,currentWaveform+(p.waveformIndex-1)*2.5);
                    currentWaveform = [];
                % if we are at the end of the playlist draw the last
                % waveform regardless of the trigger setting.
                elseif ind == playlistSize
                    plot(ax,currentWaveform+(p.waveformIndex-1)*2.5);
                    currentWaveform = [];
                end
            end
        end

        
        function save(obj)
            % saving code here
        end
        
        function load(obj)
            % code to load a waveset from a saved file?
        end
    
    end
end
        