classdef waveset < handle
    % Object/interface for using the ultrafast AWG (M8195A). 
    % Abstract experiment code will generates the waveset object.
    % M8195A object will has methods for loading/running wavesets.

    properties
        % M8195A Settings
        samplingRate = 32e9; 
        %currently not used
        % triggerRate = 1/111e6;
        % voltageRange = .5; % Output range of AWG in Volts
        
        % Object Arrays
        segmentLibrary; % array of segment objects
        playlist; % array of playlist items to organize segments
    end
    
    methods
        function obj=wavesetM8195A() % constructor
            % generating an empty waveset object.
        end
        
        function s = newSegment(obj,waveform,marker,varargin)
            % create a new segment from waveform and add it to the
            % segmentLibrary. automatically sets id. Segments are handle 
            % objects so the returned segment can be altered 
            % (channel, quadrature etc.) and those 
            % changes will show up in the segmentLibrary
            s=paramlib.M8195A.segment(waveform,marker,varargin{:});
            obj.addSegment(s);
        end
        
        function addSegment(obj,segment)
            % adds a segment object into the segmentLibrary. If segment.id
            % is not defined it will generate one
            if isempty(obj.segmentLibrary)
                if isempty(segment.id)
                    newId = 1;
                    segment.id = newId; % change segment's id
                end
                obj.segmentLibrary = segment; 
            else
                newId = size(obj.segmentLibrary,2) + 1;
                if isempty(segment.id)
                    segment.id = newId; % change segment's id
                end
                obj.segmentLibrary(newId) = segment; % add segment to end of library    
            end
        end
        
        function p = newPlaylistItem(obj,segment,varargin)
            % appends a new playlistItem to the end of the playlist.
            % playlistItems are handle objects so the returned
            % object can be altered and those changes propagate correctly
            p=paramlib.M8195A.playlistItem(segment,varargin{:});
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
            % array of subplot handles for each channel
            h(1)=subplot(1,4,1);hold(h(1),'on');
            title('Segment Library')
            h(2)=subplot(1,4,2);hold(h(2),'on');
            h(3)=subplot(1,4,3);hold(h(3),'on');
            h(4)=subplot(1,4,4);hold(h(4),'on');
            for ind = 1:libSize
                s = obj.segmentLibrary(ind);
                for ch=1:4
                    if any(s.channelMap(ch,:))
                        ax=h(ch);
                        y = s.waveform;
                        y = s.waveform+2.5*(ind-1);
                        x = tstep.*(0:(length(y)-1));
                        plot(ax,x,y)
                    end
                end
            end
        end
        
        function drawPlaylist(obj)
            % visualize the playlist
            playlistSize = size(obj.playlist,2);
            tstep = 1/obj.samplingRate;
            figure();
            % array of subplot handles for each channel
            h(1)=subplot(1,4,1);hold(h(1),'on');
            title('Playlist')
            h(2)=subplot(1,4,2);hold(h(2),'on');
            h(3)=subplot(1,4,3);hold(h(3),'on');
            h(4)=subplot(1,4,4);hold(h(4),'on');
            currentWaveform{1} = [];
            currentWaveform{2} = [];
            currentWaveform{3} = [];
            currentWaveform{4} = [];
            for ind = 1:playlistSize
                p = obj.playlist(ind);
                segId = p.segment.id; 

                % must find and add all segments in segmentLibrary to their respective channels!
                libSize = size(obj.segmentLibrary,2);
                segGroup=[];
                for ind2 = 1:libSize
                    sTemp = obj.segmentLibrary(ind2);
                    if sTemp.id == segId
                        segGroup = [segGroup sTemp];
                    end
                end
                
                % run through segment group and add each on to the correct waveform
                for ind3 = 1:length(segGroup);
                    s = segGroup(ind3);
                    % run through 4 possible channels this segment could be
                    % assigned to
                    for ch=1:4
                        if any(s.channelMap(ch,:))
                            w = s.waveform;
                            y = repmat(w,1,p.loops);
                            currentWaveform{ch} = [currentWaveform{ch} y];
                            % whenever conditional trigger setting found, we are done with a waveform.
                            if strcmp(p.advance,'Conditional') % plot and reset
                                plot(h(ch),currentWaveform{ch}+(p.waveformIndex-1)*2.5);
                                currentWaveform{ch} = [];
                            elseif strcmp(p.advance,'Stepped') % plot and reset
                                plot(h(ch),currentWaveform{ch}+(p.waveformIndex-1)*2.5);
                                currentWaveform{ch} = [];
                            elseif ind == playlistSize
                                plot(h(ch),currentWaveform{ch}+(p.waveformIndex-1)*2.5);
                                currentWaveform{ch} = [];
                            end
                        end
                    end
                end
            end
        end
                
        function save(obj)
            % saving code here...
        end
        
        function load(obj)
            % loading code here...
        end
    
    end
end
        