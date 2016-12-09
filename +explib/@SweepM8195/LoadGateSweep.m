function LoadGateSweep(self, segsize)
    % Download waveforms for qubit gate sequences
    
    % Time axis
    t = (0:segsize-1)/self.pulseCal.samplingRate;
    
    % Trigger waveform
    trigWaveform = ones(1, length(t)).*(t>10e-9).*(t<510e-9);
    
    % LO waveform
    if ~isempty(self.lochannel) && (self.lochannel ~= self.cavitychannel)
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
    if self.bgsubtraction && ~self.histogram
        if isempty(self.bgFreq)
            bgWaveform = zeros(1, length(t));
        else
            iBgCarrier = cos(2*pi*self.bgFreq*t);
            qBgCarrier = sin(2*pi*self.bgFreq*t);
        end
    end
    
    % Qubit carrier
    iQubitCarrier = cos(2*pi*self.pulseCal.qubitFreq*t);
    qQubitCarrier = sin(2*pi*self.pulseCal.qubitFreq*t);
    
    % Channel mapping vector
    % channel 1: [1 0; 0 0; 0 0; 0 0]; channel 2: [0 0; 1 0; 0 0; 0 0], etc.
    table = [1 0; 2 0; 3 0; 4 0];
    qubitCh = (table == self.qubitchannel);
    cavityCh = (table == self.cavitychannel);
    if ~isempty(self.lochannel) && (self.lochannel ~= self.cavitychannel)
        loCh = (table == self.lochannel);
    end
    if ~isempty(self.triggerchannel)
        trigCh = (table == self.triggerchannel);
    end
    
    % For repeating gates, pre-calculate baseband waveform for all primitive gates
    % in order to speed up gate calibration and randomized benchmarking
    if isprop(self, 'gatedict')
        iGateWaveforms = struct();
        qGateWaveforms = struct();
        for gateName = fieldnames(self.gatedict)'
            tGate = 0:1/self.pulseCal.samplingRate:self.gatedict.(gateName{1}).totalDuration;
            [iGateWaveforms.(gateName{1}), qGateWaveforms.(gateName{1})] ...
                = self.gatedict.(gateName{1}).uwWaveforms(tGate, 0);
        end
    end
    
    segID = 1;
    numsegs = length(self.sequences);
    % Main loop for downloading waveforms to AWG
    for ind = 1:numsegs
        display(['loading sequence ', num2str(ind), ' of ', num2str(numsegs)]);
        s = self.sequences(ind);
        try
            % Use pre-calculated baseband waveforms if possible
            iQubitBase = zeros(1, length(t));
            qQubitBase = zeros(1, length(t));
            start = find(t>=(self.sequenceEndTime - s.totalSequenceDuration), 1);
            for col = 1:len(s)
                % For each gate in the current sequence s
                gateName = s.gateArray{col}.name;
                % Find pre-calculated baseband waveform by its name
                itemp = iGateWaveforms.(gateName);
                qtemp = qGateWaveforms.(gateName);
                % Update the corresponding segment in the waveform
                stop = start + length(itemp) - 1;
                iQubitBase(start:stop) = itemp;
                qQubitBase(start:stop) = qtemp;
                % Go to next gate
                start = stop;
            end
        catch
            % Otherwise calculate waveforms from gateSequence object
            [iQubitBase, qQubitBase] = s.uwWaveforms(t, self.sequenceEndTime - s.totalSequenceDuration);
        end
        
        % Multiply the carrier
        qubitWaveform = iQubitBase.*iQubitCarrier + qQubitBase.*qQubitCarrier;
                
        % Load waveform
        if isempty(self.triggerchannel)
        % 2-channel marker mode, trigger is passed as marker
            if self.qubitchannel == self.cavitychannel
                % qubit and cavity pulses in one channel
                iqdownload(qubitWaveform+cavityWaveform, self.pulseCal.samplingRate, ...
                           'channelMapping', qubitCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            else
                % qubit and cavity pulses in two channels
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
                % if direct synthesizing LO
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
                           'keepOpen', 1, 'run', 0);
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
            if ~isempty(self.bgFreq)
                bgWaveform = iQubitBase.*iBgCarrier + qQubitBase.*qBgCarrier;
            end
            clear iQubitBase qQubitBase;
            
            if isempty(self.triggerchannel)
                if self.qubitchannel == self.cavitychannel
                    iqdownload(bgWaveform+cavityWaveform, self.pulseCal.samplingRate, ...
                               'channelMapping', qubitCh, ...
                               'segmentNumber', segID, ...
                               'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
                else
                    iqdownload(bgWaveform, self.pulseCal.samplingRate, ...
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
                if self.qubitchannel == self.cavitychannel
                    iqdownload(bgWaveform+cavityWaveform, self.pulseCal.samplingRate, ...
                               'channelMapping', qubitCh, ...
                               'segmentNumber', segID, ...
                               'keepOpen', 1, 'run', 0);
                else
                    iqdownload(bgWaveform, self.pulseCal.samplingRate, ...
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