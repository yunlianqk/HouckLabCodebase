function SeqStop(self,PlayList)
% function that runs a sequence playlist based on the previously downloaded waveform library
% Sequence playlist must have the following struct format
% sequence entry i
%       playlist(i).segmentNumber = segment id # specified in WaveLib
%       playlist(i).segmentLoops = # of loops before next waveform in the playlist
%       playlist(i).markerEnable = true (default)
%       playlist(i).segmentAdvance = 'Auto' - next waveform starts immediately
%                                    'Conditional' - next waveform after trigger

    iqseq('define', PlayList, 'keepOpen', 1, 'run', 0);
    
end