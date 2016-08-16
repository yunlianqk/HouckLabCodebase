function wavelib = WavesetExtractSegmentLibraryStruct(self,waveset)
% translates segmentLibrary object (from paramlib.M8195A) into struct used 
% by iqtools. 
    s = waveset.segmentLibrary;
    for ind=1:length(s)
        wavelib(ind).waveform = s(ind).waveform;
        wavelib(ind).channelMap = s(ind).channelMap;
        wavelib(ind).segNumber = s(ind).id;
        wavelib(ind).keepOpen = s(ind).keepOpen;
        wavelib(ind).run = s(ind).run;
        wavelib(ind).correction = s(ind).applyFilter;
        wavelib(ind).marker = s(ind).marker;
    end
end