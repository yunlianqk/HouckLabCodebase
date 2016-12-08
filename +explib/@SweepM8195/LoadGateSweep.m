function LoadGateSweep(self, segsize)
    % Download waveforms for qubit gate sequences
    
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
    % channel 1: [1 0; 0 0; 0 0; 0 0]; channel 2: [0 0; 1 0; 0 0; 0 0]
    table = [1 0; 2 0; 3 0; 4 0];
    qubitCh = (table == self.qubitchannel);
    cavityCh = (table == self.cavitychannel);
    if ~isempty(self.lochannel)
        loCh = (table == self.lochannel);
    end
    
    % For repeating gates, pre-calculate baseband waveform for all primitive gates
    % in order to speed up gate calibration and randomized benchmarking
    if isprop(self, 'gatedict')
        iGateWaveforms = struct();
        qGateWaveforms = struct();
        for gateName = fieldnames(self.gatedict)'
            tGate = 0:1/awg.samplerate:self.gatedict.(gateName{1}).totalDuration;
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
            if ~isempty(self.bgFreq)
                bgWaveform = iQubitBase.*iBgCarrier + qQubitBase.*qBgCarrier;
            end
            clear iQubitBase qQubitBase;
            
            if self.qubitchannel == self.cavitychannel
                iqdownload(bgWaveform+cavityWaveform, awg.samplerate, ...
                           'channelMapping', qubitCh, ...
                           'segmentNumber', segID, ...
                           'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            else
                iqdownload(bgWaveform, awg.samplerate, ...
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
        end
    end
    % Last playlist must have advance set to 'auto'
    self.playlist(end).segmentAdvance = 'Auto';
end