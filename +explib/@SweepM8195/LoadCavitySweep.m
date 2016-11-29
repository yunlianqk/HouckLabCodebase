function LoadCavitySweep(self, segsize)

    global awg;
    % create time axis with correct size
    t = (0:segsize-1)/awg.samplerate;
    
    % generate trigger waveforms
    trigWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);
    
    % generate baseband measurement pulse
    [iMeasBase, qMeasBase] = self.measurement.uwWaveforms(t, self.measStartTime);
    
    s = self.sequences(1);
    [iQubitBase, qQubitBase] = s.uwWaveforms(t, self.sequenceEndTime - s.totalSequenceDuration);
    qubitwaveform = iQubitBase.*cos(2*pi*self.pulseCal.qubitFreq*t) ...
                    + qQubitBase.*sin(2*pi*self.pulseCal.qubitFreq*t);
    clear iQubitBase qQubitBase;
    
    if self.cavitybaseband
        numsegs = 1;
    else
        numsegs = length(self.cavityFreq);
    end
    
    % Background is zeros
    bgwaveform = zeros(1, length(t));
    
    for ind = 1:numsegs
        display(['loading sequence ', num2str(ind), ' of ', num2str(numsegs)]);

        % For baseband mode, channel 2 is baseband measurement pulse
        if self.cavitybaseband
            ch2waveform = iMeasBase;
            ch1waveform = qubitwaveform;
        % For direct mode, channel 2 is LO, measurement pulse contains carrier
        else
            ch2waveform = sin(2*pi*(self.cavityFreq(ind)+self.pulseCal.intFreq)*t);
            ch1waveform = qubitwaveform ...
                          + iMeasBase.*cos(2*pi*self.cavityFreq(ind)*t) ...
                          + qMeasBase.*sin(2*pi*self.cavityFreq(ind)*t);
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
            iqdownload(bgwaveform, awg.samplerate, ...
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