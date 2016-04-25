classdef waveSetM8195A < handle
    % A 'waveset' object contains a set of microwave, trigger, gating, etc. 
    % waveforms ready to be either saved or uploaded to the relevant AWG.
    % An experiment object should have a method to generate the waveset 
    % object.  The waveset object should then have it's own methods for
    % saving or uploading to the AWG as needed.
    % M8195a is the superfast 65GS/s direct synthesis AWG.
    
    properties
        samplingRate; 
        channels; % an array of structs
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
        
        function obj=addChannel(obj,channelNumber, waveform)
            newChan.channelNumber=channelNumber;
            w=obj.padWaveform(waveform);
            newChan.waveform=waveform;
            channels=obj.channels;
            channels=[channels newChan];
            obj.channels=channels;
        end
        
        function w=padWaveform(obj,waveform)
            fprintf(['input waveform length: ' num2str(length(waveform))]);
            w = waveform;
        end
        
        function draw(obj)
            % visualize
            nc=length(obj.channels)
            sr=obj.samplingRate;
            t=0:1/sr:((length(obj.channels(1).waveform)-1)/obj.samplingRate);
            figure(61)
            for ind=1:nc
                subplot(nc,1,ind)
                plot(t,obj.channels(ind).waveform)
                title(['channel ' num2str(obj.channels(ind).channelNumber)])
            end
            
        end
        
        function saveCSV(obj)
            [FileName,PathName] = uiputfile('*.dat');
            nc=length(obj.channels);
            ns=length(obj.channels(1).waveform);
            data=zeros(nc,ns);
            for ind=1:nc
                data(ind,:)=obj.channels(ind).waveform;
            end
            csvwrite([PathName FileName],data);
        end
        
        % other functions to implement
        % save waveset as csv 
        % apply predistortion filter
        % upload waveforms to AWG
    end
end