function LoadQubitSweep(self, segsize)
    % Download waveforms for sweeping qubit frequency
    
    global awg;
    % Time axis
    t = (0:segsize-1)/awg.samplerate;
    
    % Trigger waveform
    trigWaveform = ones(1, length(t)).*(t>10e-9).*(t<510e-9);
    
    % LO waveform
    if ~isempty(self.lochannel)
        loWaveform = self.pulseCal.loAmplitude ...
                     *cos(2*pi*(self.pulseCal.cavityFreq+self.pulseCal.intFreq)*t);
    end
    
    % Measurement waveform
    % For baseband mode
    [cavityWaveform, ~] = self.measurement.uwWaveforms(t, self.measStartTime);
    % For direct mode    
    if ~self.cavitybaseband
        cavityWaveform = cos(2*pi*self.pulseCal.cavityFreq*t).*cavityWaveform;
    end
    
    % Background waveform
    if self.bgsubtraction
        if self.qubitchannel == self.cavitychannel
            bgWaveform = cavityWaveform;
        else
            bgWaveform = zeros(1, length(t));
        end
    end
     
    % Channel mapping vector
    % channel 1: [1 0; 0 0; 0 0; 0 0]; channel 2: [0 0; 1 0; 0 0; 0 0]
    table = [1 0; 2 0; 3 0; 4 0];
    qubitCh = (table == self.qubitchannel);
    cavityCh = (table == self.cavitychannel);
    if ~isempty(self.lochannel)
        loCh = (table == self.lochannel);
    end
       
    % If sweep qubit frequency, gate sequence is ignored and only first sequence is used
    s = self.sequences(1);
    [iQubitBase, qQubitBase] = s.uwWaveforms(t, self.sequenceEndTime - s.totalSequenceDuration);

    segID = 1;
    numsegs = length(self.qubitFreq);
    % Main loop for downloading waveforms to AWG
    for ind = 1:numsegs
        display(['loading sequence ', num2str(ind), ' of ', num2str(numsegs)]);
        % Each segment has different qubit frequency
        qubitWaveform = iQubitBase.*cos(2*pi*self.qubitFreq(ind)*t) ...
                      + qQubitBase.*sin(2*pi*self.qubitFreq(ind)*t);

        % Load waveform
        if self.qubitchannel == self.cavitychannel
            iqdownload(qubitWaveform+cavityWaveform, awg.samplerate, ...
                       'channelMapping', qubitCh, ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
        else
            iqdownload(qubitWaveform, awg.samplerate, ...
                       'channelMapping', qubitCh, ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            iqdownload(cavityWaveform, awg.samplerate, ...
                       'channelMapping', cavityCh, ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
        end
        if ~isempty(self.lochannel)
            iqdownload(loWaveform, awg.samplerate, ...
                       'channelMapping', loCh, ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
        end
        % Create playlists
        self.playlist(segID).segmentNumber = segID;
        self.playlist(segID).segmentLoops = 1;
        self.playlist(segID).markerEnable = true;
        self.playlist(segID).segmentAdvance = 'Stepped';
        segID = segID + 1;
        
        % Load background
        if self.bgsubtraction && ~self.histogram
            iqdownload(bgWaveform, awg.samplerate, ...
                       'channelMapping', qubitCh, ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            if self.qubitchannel ~= self.cavitychannel
                iqdownload(cavityWaveform, awg.samplerate, ...
                           'channelMapping', cavityCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            end
            if ~isempty(self.lochannel)
                iqdownload(loWaveform, awg.samplerate, ...
                           'channelMapping', loCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            end
            % Create playlists
            self.playlist(segID).segmentNumber = segID;
            self.playlist(segID).segmentLoops = 1;
            self.playlist(segID).markerEnable = true;
            self.playlist(segID).segmentAdvance = 'Stepped';
            segID = segID + 1;
        end
    end
    % Last playlist must have advance set to 'auto'
    self.playlist(end).segmentAdvance = 'Auto';
end