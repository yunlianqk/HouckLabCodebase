function [WaveLib] = WavesetApplyCorrection(self,waveset)
% function for applying FIR corection to library waveforms.
% this applies the filter to the waveset object as opposed to the wavelib
% struct, allowing you to inspect the results.  Also when it's applied it
% will set all of the applyFilter parameters to 0 so the filter won't get
% applied multiple times.
% [!] Waveform correction needs to be done prior to download
% this uses the waveset objects found in paramlib.M8195A
    segLib=waveset.segmentLibrary;
    for i=1:length(segLib)
        if(segLib(i).applyFilter)
            segLib(i).waveform = iqcorrection(segLib(i).waveform, self.samplerate);
            segLib(i).applyFilter = false;
        end
    end
end