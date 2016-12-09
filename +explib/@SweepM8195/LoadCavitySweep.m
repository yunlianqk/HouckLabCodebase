function LoadCavitySweep(self, segsize)
    % Download waveforms for sweeping cavity frequency

    % Time axis
    t = (0:segsize-1)/self.pulseCal.samplingRate;
    
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
    if self.bgsubtraction && ~self.histogram
        bgWaveform = zeros(1, length(t));
    end
    
    % Channel mapping vector
    % channel 1: [1 0; 0 0; 0 0; 0 0]; channel 2: [0 0; 1 0; 0 0; 0 0]
    table = [1 0; 2 0; 3 0; 4 0];
    qubitCh = (table == self.qubitchannel);
    cavityCh = (table == self.cavitychannel);
    if ~isempty(self.lochannel) && (self.lochannel ~= self.cavitychannel)
        loCh = (table == self.lochannel);
    end
    if ~isempty(self.triggerchannel)
        trigCh = (table == self.triggerchannel);
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
        if ~isempty(self.lochannel) && (self.lochannel ~= self.cavitychannel)
            loWaveform = self.pulseCal.loAmplitude ...
                         *cos(2*pi*(self.pulseCal.cavityFreq+self.pulseCal.intFreq)*t);
        end
        
        % Load waveform
        if isempty(self.triggerchannel)
        % 2-channel marker mode, trigger is passed as marker
            if self.qubitchannel == self.cavitychannel
                iqdownload(qubitWaveform+cavityWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', qubitCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            else
                iqdownload(qubitWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', qubitCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
                iqdownload(cavityWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', cavityCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            end
            if ~isempty(self.lochannel) && (self.lochannel ~= self.cavitychannel)
                iqdownload(loWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', loCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            end
        else
        % 4-channel mode, trigger is passed a separate channel
            if self.qubitchannel == self.cavitychannel
                iqdownload(qubitWaveform+cavityWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', qubitCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0);
            else
                iqdownload(qubitWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', qubitCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0);
                iqdownload(cavityWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', cavityCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0);
            end
            iqdownload(trigWaveform, self.pulseCal.samplingRate, ...
                       'channelMapping', trigCh, ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0);
            if ~isempty(self.lochannel) && (self.lochannel ~= self.cavitychannel)
                iqdownload(loWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', loCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            end
        end
        % Create playlists
        self.playlist(segID).segmentNumber = segID;
        self.playlist(segID).segmentLoops = 1;
        self.playlist(segID).markerEnable = true;
        self.playlist(segID).segmentAdvance = 'Stepped';
        segID = segID + 1;
        
        % Load background        
        if self.bgsubtraction && ~self.histogram
            if isempty(self.triggerchannel)
                iqdownload(bgWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', qubitCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
                if self.qubitchannel ~= self.cavitychannel
                    iqdownload(bgWaveform, self.pulseCal.samplingRate, ...
                               'channelMapping', cavityCh, ...
                               'segmentNumber', segID, ...
                               'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
                end
                if ~isempty(self.lochannel) && (self.lochannel ~= self.cavitychannel)
                    iqdownload(loWaveform, self.pulseCal.samplingRate, ...
                               'channelMapping', loCh, ...
                               'segmentNumber', segID, ...
                               'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
                end
            else
                iqdownload(bgWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', qubitCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0);
                if self.qubitchannel ~= self.cavitychannel
                    iqdownload(bgWaveform, self.pulseCal.samplingRate, ...
                               'channelMapping', cavityCh, ...
                               'segmentNumber', segID, ...
                               'keepOpen', 1, 'run', 0);
                end
                iqdownload(trigWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', trigCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0);
                if ~isempty(self.lochannel) && (self.lochannel ~= self.cavitychannel)
                    iqdownload(loWaveform, self.pulseCal.samplingRate, ...
                               'channelMapping', loCh, ...
                               'segmentNumber', segID, ...
                               'keepOpen', 1, 'run', 0);
                end
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