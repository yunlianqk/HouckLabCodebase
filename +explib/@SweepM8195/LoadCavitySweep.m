function LoadCavitySweep(self, segsize)
    % Download waveforms for sweeping cavity frequency
    
    global awg;
    % Time axis
    t = (0:segsize-1)/awg.samplerate;
    
    % Trigger waveform
    trigWaveform = ones(1,length(t)).*(t>10e-9).*(t<510e-9);

    % Baseband measurement waveform
    [cavityBase, ~] = self.measurement.uwWaveforms(t, self.measStartTime);
    
    % If sweep cavity frequency, gate sequence is ignored and only first sequence is used
    s = self.sequences(1);
    [iQubitBase, qQubitBase] = s.uwWaveforms(t, self.sequenceEndTime - s.totalSequenceDuration);
    qubitWaveform = iQubitBase.*cos(2*pi*self.pulseCal.qubitFreq*t) ...
                    + qQubitBase.*sin(2*pi*self.pulseCal.qubitFreq*t);
    clear iQubitBase qQubitBase;

    % Background waveform is zeros
    bgWaveform = zeros(1, length(t));
    
    % Channel mapping vector
    % channel 1: [1 0; 0 0; 0 0; 0 0]; channel 2: [0 0; 1 0; 0 0; 0 0]
    table = [1 0; 2 0; 3 0; 4 0];
    qubitCh = (table == self.qubitchannel);
    cavityCh = (table == self.cavitychannel);
    if ~isempty(self.lochannel)
        loCh = (table == self.lochannel);
    end
    
    if self.cavitybaseband
        numsegs = 1;
    else
        numsegs = length(self.cavityFreq);
    end
    segID = 1;
    % Main loop for downloading waveforms to AWG
    for ind = 1:numsegs
        display(['loading sequence ', num2str(ind), ' of ', num2str(numsegs)]);

        % Cavity waveform
        if self.cavitybaseband
            % For baseband mode
            cavityWaveform = cavityBase;
        else
            % For direct mode
            cavityWaveform = cavityBase.*cos(2*pi*self.cavityFreq(ind)*t);
        end
        
        % LO waveform
        if ~isempty(self.lochannel)
            loWaveform = self.pulseCal.loAmplitude ...
                         *cos(2*pi*(self.pulseCal.cavityFreq+self.pulseCal.intFreq)*t);
        end
        
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
                iqdownload(bgWaveform, awg.samplerate, ...
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