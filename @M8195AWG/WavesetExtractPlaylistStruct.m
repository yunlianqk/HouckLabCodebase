function playlist = WavesetExtractPlaylistStruct(self,waveset)
% translates playlist object (from paramlib.M8195A) into playlist struct used 
% by iqtools. 
    p = waveset.playlist;
    for ind=1:length(p)
        playlist(ind).segmentNumber = p(ind).segment.id;
        playlist(ind).segmentLoops = p(ind).loops;
        playlist(ind).markerEnable = p(ind).markerEnable;
        playlist(ind).segmentAdvance = p(ind).advance;
    end
end