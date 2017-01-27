function Wavedownload(self,WaveLib,amplitude)
% function download waveform library to awg memory
% waveforms to be used in predefined sequence playlist
% [!] Waveform correction needs to be done prior to download
% WaveLib input needs to have the following struct format
% Library entry i:
%   wavelib(i).waveform = waveform vector
%   wavelib(i).channelMap = channel mapping [Ch1I Ch1Q; Ch2I Ch2Q; Ch3I Ch3Q; Ch4I Ch4Q]
%   wavelib(i).segNumber = segment id # to be referenced in the sequence playlist
%   wavelib(i).keepOpen = 1 (default)
%   wavelib(i).run = 0 (default), 1 will run the waveform immediately after downloading it
%   wavelib(i).correction = 1 (true) if you want to apply FIR filter, 0 otherwise

    if length(varargin)==0
        amplitude= [1 1];
    else
       disp('rea') 
    end
        
    % start from scratch and delete all segments
    iqseq('delete', [], 'keepOpen', 1);

    % If waveform library is too big
    if length(WaveLib)>self.maxSegNumber
        error(['Waveform library size exceeds maximum segment number ',int2str(self.maxSegNumber)]);
    end

    % Correct waveform length to ensure it's a multiple of segment granularity
    for i=1:length(WaveLib)
    % If waveform size is smaller than minimum segment size
        if length(WaveLib(i).waveform)<self.minSegSize
            error(['Waveform library entry ',int2str(i),...
                ' is smaller than minimum segment size ',int2str(self.minSegSize)]);
        end
        
    % If waveform size is larger than maximum segment size
        if length(WaveLib(i).waveform)>self.maxSegSize
            error(['Waveform library entry ',int2str(i),...
                ' is larger than maximum segment size ',int2str(self.maxSegSize)]);
        end
        
    % Correct waveform length to ensure it's a multiple of segment granularity
    % pad the waveform with extra zero  valued samples
        newlength=ceil(length(WaveLib(i).waveform)/self.granularity)*self.granularity;
        old=WaveLib(i).waveform;
        newWaveform = [old,zeros(1,newlength-length(old))];
        old=WaveLib(i).marker;
        newMarker = [old,zeros(1,newlength-length(old))];
        
        iqdownload(newWaveform,...
            self.samplerate,...
            'channelMapping',...
            WaveLib(i).channelMap,...
            'segmentNumber',...
            WaveLib(i).segNumber,...
            'keepOpen',...
            WaveLib(i).keepOpen,...
            'run',...
            WaveLib(i).run,...
            'marker',...
            newMarker,...
            'amplitude',...
            amplitude);
        
    end
end