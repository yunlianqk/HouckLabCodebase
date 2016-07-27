function WavesetDownloadSegmentLibrary(self, waveset)
% takes a paramlib.M8195A.waveset object and downloads the segment library
    WaveLib = self.WavesetExtractSegmentLibraryStruct(self, waveset);
    self.Wavedownload(WaveLib);
end
