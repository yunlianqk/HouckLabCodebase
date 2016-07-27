function wavelib = WavesetExtractSegmentLibraryStruct(self,waveset)
% translates segmentLibrary object (from paramlib.M8195A) into struct used 
% by iqtools. 
    s = waveset.segmentLibrary;
    for ind=1:length(s)
        wavelib(i).waveform = s.waveform;
        wavelib(i).channelMap = s.channelMap;
        wavelib(i).segNumber = s.id;
        wavelib(i).keepOpen = s.keepOpen;
        wavelib(i).run = s.run;
        wavelib(i).correction = s.applyFilter;
    end
end