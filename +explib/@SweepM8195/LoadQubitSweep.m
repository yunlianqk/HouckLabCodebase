function LoadQubitSweep(self, segsize)

    global awg;
    % create time axis with correct size
    t = (0:segsize-1)/awg.samplerate;
    
    % generate trigger waveforms
    trigWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
    
    % generate measurement pulse
    [iMeasBase, qMeasBase] = self.measurement.uwWaveforms(t, self.measStartTime);
    
    % For baseband mode, channel 2 is baseband measurement pulse
    % background is zeros in channel 1
    if self.cavitybaseband
        ch2waveform = iMeasBase;
        bgwaveform = zeros(1, length(t));
    % For direct mode, channel 2 is LO, measurement pulse contains carrier
    % background is measurement pulse in channel 1
    else
        ch2waveform = sin(2*pi*(self.pulseCal.cavityFreq+self.pulseCal.intFreq)*t);
        bgwaveform = iMeasBase.*cos(2*pi*self.pulseCal.cavityFreq*t) ...
                     + qMeasBase.*sin(2*pi*self.pulseCal.cavityFreq*t);
    end
    clear iMeasBase qMeasBase;
    
    % If sweep qubit frequency, gate sequence is ignored and only first
    % sequence is used
    numsegs = length(qubitFreq);
    s = self.sequences(1);
    [iQubitBase, qQubitBase] = s.uwWaveforms(t, self.sequenceEndTime - s.totalSequenceDuration);
    
    for ind = 1:numsegs
        display(['loading sequence ', num2str(ind), ' of ', num2str(numsegs)]);

        ch1waveform = iQubitBase.*cos(2*pi*self.qubitFreq(ind)*t) ...
                      + qQubitBase.*sin(2*pi*self.qubitFreq(ind)*t);

        if ~self.cavitybaseband
            ch1waveform = ch1waveform + bgwaveform; 
        end

        if self.bgsubtraction
            segID = ind*2-1;
        else
            segID = ind;
        end
        % load channel 1
        iqdownload(ch1waveform, awg.samplerate, ...
                   'channelMapping', [1 0; 0 0; 0 0; 0 0], ...
                   'segmentNumber', segID, ...
                   'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
        clear ch1waveform;
        % load channel 2
        iqdownload(ch2waveform, awg.samplerate, ...
                   'channelMapping', [0 0; 1 0; 0 0; 0 0], ...
                   'segmentNumber', segID, ...
                   'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
        % create data self.playlist entry
        self.playlist(segID).segmentNumber = segID;
        self.playlist(segID).segmentLoops = 1;
        self.playlist(segID).markerEnable = true;
        self.playlist(segID).segmentAdvance = 'Stepped';
        
        if self.bgsubtraction
            segID = ind*2;
            % load background segment
            iqdownload(bgwaveform, awg.samplerate, ...
                       'channelMapping', [1 0; 0 0; 0 0; 0 0], ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            iqdownload(ch2waveform, awg.samplerate, ...
                       'channelMapping', [0 0; 1 0; 0 0; 0 0], ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            % create background self.playlist entry
            self.playlist(segID).segmentNumber = segID;
            self.playlist(segID).segmentLoops = 1;
            self.playlist(segID).markerEnable = true;
            self.playlist(segID).segmentAdvance = 'Stepped';
        end
    end
    % last self.playlist item must have advance set to 'auto'
    self.playlist(segID).segmentAdvance = 'Auto';
end