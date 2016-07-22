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
        
        function obj=addSegment(obj,segment)
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
        
        function draw()
            % visualize the segment library 
            % visualize playlist
        end

        function save(obj)
            % saving code here
        end
        
        function load(obj)
            % code to load a waveset from a saved file?
        end
    
    end
end
        