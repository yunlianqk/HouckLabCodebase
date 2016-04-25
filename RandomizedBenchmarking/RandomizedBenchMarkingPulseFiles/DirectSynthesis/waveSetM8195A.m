classdef waveSetM8195A < handle
    % A 'waveset' object contains a set of microwave, trigger, gating, etc. 
    % waveforms ready to be either saved or uploaded to the relevant AWG.
    % An experiment object should have a method to generate the waveset 
    % object.  The waveset object should then have it's own methods for
    % saving or uploading to the AWG as needed.
    % M8195a is the superfast 65GS/s direct synthesis AWG.
    
    properties
        samplingRate; 
        channels; % object array of channels
    end
    
    methods
        function obj=waveSetM8195A()
            % constructor is empty - create object then change settings and
            % load channel structs. 
            
            % this stuff done in property set functions
            % load settings into obj
            % check waveform sample #'s
            % pad waveforms with 0's if necessary
        end
        
        function obj = set.samplingRate(obj,value)
            % check if valid sampling rate?
            obj.samplingRate=value;
            % do we need to update anything else? 
        end
        
        % other functions to implement
        % draw
        % save
        % apply filter
        % apply settings
        % upload waveforms to AWG
        % add channel
        % update channel?
        
    end
end