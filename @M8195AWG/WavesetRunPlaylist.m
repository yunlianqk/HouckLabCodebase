function WavesetRunPlaylist(self,waveset)
% takes a paramlib.M8195A.waveset object and runs the playlist. segment
% library must already be downloaded
    Playlist = WavesetExtractPlaylistStruct(self,waveset);
    self.SeqRun(self,PlayList)
end