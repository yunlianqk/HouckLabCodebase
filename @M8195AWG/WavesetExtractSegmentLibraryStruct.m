function wavelib = WavesetExtractSegmentLibraryStruct(self,waveset)
% translates segmentLibrary object (from paramlib.M8195A) into struct used 
% by iqtools. 
    s = waveset.segmentLibrary;
    for ind=1:length(s)
        wavelib(i).waveform = s(ind).waveform;
        wavelib(i).channelMap = s(ind).channelMap;
        wavelib(i).segNumber = s(ind).id;
        wavelib(i).keepOpen = s(ind).keepOpen;
        wavelib(i).run = s(ind).run;
        wavelib(i).correction = s(ind).applyFilter;
        wavelib(i).marker = s(ind).marker;
    end
end