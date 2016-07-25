function [WaveLib] = ApplyCorrection(self,WaveLib)
% function for applying FIR corection to library waveforms 
% [!] Waveform correction needs to be done prior to download
% WaveLib input needs to have the following struct format
% Library entry i:
%   wavelib(i).waveform = waveform vector
%   wavelib(i).channelMap = channel mapping [Ch1I Ch1Q; Ch2I Ch2Q; Ch3I Ch3Q; Ch4I Ch4Q]
%   wavelib(i).segNumber = segment id # to be referenced in the sequence playlist
%   wavelib(i).keepOpen = 1 (default)
%   wavelib(i).run = 0 (default), 1 will run the waveform immediately after downloading it
%   wavelib(i).correction = 1 (true) if you want to apply FIR filter, 0 otherwise

    for i=1:length(WaveLib)
        if(WaveLib(i).correction)
            WaveLib(i).waveform = iqcorrection(WaveLib(i).waveform, self.samplerate);
        end
    end
end