function LoadGateSweep(self, segsize)

    global awg;
    % create time axis
    t = (0:segsize-1)/awg.samplerate;
    
    % generate trigger waveform
    trigWaveform = ones(1, length(t)).*(t>10e-9).*(t<510e-9);
    % generate marker waveform
    mkrWaveform = ones(1, length(t)).*(t>self.measStartTime-25e-9) ...
                  .*(t<self.measStartTime+self.measurement.totalDuration+25e-9);
    % generate measurement pulse
    [iMeas, qMeas] = self.measurement.uwWaveforms(t, self.measStartTime);
    
    % For baseband mode, channel 2 is baseband measurement pulse
    % background is zeros in channel 1
    if self.cavitybaseband
        ch2waveform = iMeas;
        bgwaveform = zeros(1, length(t));
        
    % For direct mode, channel 2 is LO, measurement pulse contains carrier
    % and background is measurement pulse in channel 1
    else
        iMeas = cos(2*pi*self.pulseCal.cavityFreq*t).*iMeas;
        qMeas = sin(2*pi*self.pulseCal.cavityFreq*t).*qMeas;
        ch2waveform = sin(2*pi*(self.pulseCal.cavityFreq+self.pulseCal.intFreq)*t);
        bgwaveform = iMeas + qMeas;
    end
    clear iMeas qMeas;
    % Qubit carrier
    iQubitCarrier = cos(2*pi*self.pulseCal.qubitFreq*t);
    qQubitCarrier = sin(2*pi*self.pulseCal.qubitFreq*t);
    % For repeating gates, pre-calculate baseband waveform for all primitive gates
    if isprop(self, 'gatedict')
        iGateWaveforms = struct();
        qGateWaveforms = struct();
        for gateName = fieldnames(self.gatedict)'
            tGate = 0:1/awg.samplerate:self.gatedict.(gateName{1}).totalDuration;
            [iGateWaveforms.(gateName{1}), qGateWaveforms.(gateName{1})] ...
                = self.gatedict.(gateName{1}).uwWaveforms(tGate, tGate/2);
        end  
    end
    
    % Main loop for downloading waveforms to AWG
    segID = 1;
    numsegs = length(self.sequences);
    for ind = 1:numsegs
        display(['loading sequence ', num2str(ind), ' of ', num2str(numsegs)]);
        s = self.sequences(ind);
        try
            % Use pre-calculated waveforms if possible
            iQubitBase = zeros(1, length(t));
            qQubitBase = zeros(1, length(t));
            start = find(t>=(self.sequenceEndTime - s.totalSequenceDuration), 1);
            for col = 1:len(s)
                gateName = s.gateArray{col}.name;
                itemp = iGateWaveforms.(gateName);
                qtemp = qGateWaveforms.(gateName);
                stop = start + length(itemp) - 1;
                iQubitBase(start:stop) = itemp;
                qQubitBase(start:stop) = qtemp;
                start = stop;
            end
        catch
            % Otherwise calculate waveforms from gateSequence object
            [iQubitBase, qQubitBase] = s.uwWaveforms(t, self.sequenceEndTime - s.totalSequenceDuration);
        end
        
        ch1waveform = iQubitBase.*iQubitCarrier + qQubitBase.*qQubitCarrier + bgwaveform;
        clear iQubitBase qQubitBase;

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
                   'keepOpen', 1, 'run', 0, 'marker', mkrWaveform);
        % create data self.playlist entry
        self.playlist(segID).segmentNumber = segID;
        self.playlist(segID).segmentLoops = 1;
        self.playlist(segID).markerEnable = true;
        self.playlist(segID).segmentAdvance = 'Stepped';
        
        segID = segID + 1;
        if self.bgsubtraction && ~self.histogram
            % load background segment
            iqdownload(bgwaveform, awg.samplerate, ...
                       'channelMapping', [1 0; 0 0; 0 0; 0 0], ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', trigWaveform);
            iqdownload(ch2waveform, awg.samplerate, ...
                       'channelMapping', [0 0; 1 0; 0 0; 0 0], ...
                       'segmentNumber', segID, ...
                       'keepOpen', 1, 'run', 0, 'marker', mkrWaveform);
            % create background self.playlist entry
            self.playlist(segID).segmentNumber = segID;
            self.playlist(segID).segmentLoops = 1;
            self.playlist(segID).markerEnable = true;
            self.playlist(segID).segmentAdvance = 'Stepped';
            segID = segID + 1;
        end
    end
    % last self.playlist item must have advance set to 'auto'
    self.playlist(end).segmentAdvance = 'Auto';
end