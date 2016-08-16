function WavesetSeqStop(self,waveset)
% takes a paramlib.M8195A.waveset object and stops the running playlist
    Playlist = WavesetExtractPlaylistStruct(self,waveset);
    iqseq('define', PlayList, 'keepOpen', 1, 'run', 0);
end