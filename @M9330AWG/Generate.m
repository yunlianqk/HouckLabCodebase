function Generate(self)
% Load waveforms, create markers and generate output

    % If waveform lengths are note equal or less than 128, throw error
    for len = [size(self.waveform1, 2), size(self.waveform2, 2), ...
               size(self.marker1, 2), size(self.marker2, 2)]
        if len ~= size(self.timeaxis, 2)
            error('Waveforms, markers and timeaxis should have same length');
        end
    end
    if size(self.waveform1, 2) < 128
        error('Waveforms should contain at least 128 points');
    end
    
    if size(self.waveform1, 1) ~= size(self.waveform2, 1)
        error('Waveforms should have the same number of segments');
    end
    if self.mkrauto
        self.marker1 = double(self.waveform1 ~= 0);
        self.marker2 = double(self.waveform2 ~= 0);
    end
    % Interpolate time axis and waveforms using sampling rate
    dt = 1/self.samplingrate;
    taxis = self.timeaxis(1):dt:self.timeaxis(end);
    waveforms = [self.waveform1; self.waveform2];
    markers = [self.marker1; self.marker2];
    waveforms = interp1(self.timeaxis, waveforms', taxis)';
    markers = interp1(self.timeaxis, double(markers)', taxis)';
    % From here, first half of rows are channel 1, second half of rows are channel 2
    
    % Increase the length of time axis and waveforms to integer mulitple of 8
    newlength = ceil(length(waveforms(1,:))/8)*8;
    waveforms(:, newlength) = 0;
    markers(:, newlength) = 0;
    % Force marker to be 0/1
    markers = double(markers ~= 0);

    % Create rawdata points for AWG
    offset = [self.mkr1offset, self.mkr2offset];
    amp = [self.CH1MAXAMP, self.CH2MAXAMP];
    segments = size(waveforms, 1)/2;
    % Normalize waveforms if max value > 1.0
    for ch = 1:2
        domain = (ch-1)*segments+1:ch*segments;
        maxvalue = max(max(abs(waveforms(domain,:))));
        if maxvalue > 1.0
            waveforms(domain,:) = waveforms(domain,:)/maxvalue;
        end
    end
    for trace = 1:2*segments
        ch = ceil(trace/segments);
        % Create waveform rawdata for AWG
        waveforms(trace,:) = waveforms(trace,:)*amp(ch);
        
        % Increase marker width by 2*mkraddwidth
        for index = find(diff(markers(trace,:))) % Find all jumps in marker
            if (markers(trace, index) == 0)    % Rising edge
                markers(trace, max(1, index-self.mkraddwidth+1):index) = 1;
            else % Falling edge
                markers(trace, index+1:min(newlength, index+self.mkraddwidth)) = 1;
            end
        end
        % Shift marker by mkroffset
        if offset(ch) >= 0
            markers(trace,:) = [zeros(1, offset(ch)), ...
                             markers(trace, 1:end-offset(ch))];
        else
            markers(trace,:) = [markers(trace, 1-offset(ch):end), ...
                             zeros(1, -offset(ch))];
        end
    end
    % Convert to raw data forms
    waveforms = int16(waveforms);
    markers = uint8(markers*2^6);
    % Generate waveforms
    self.GenerateRaw(waveforms, markers);
end